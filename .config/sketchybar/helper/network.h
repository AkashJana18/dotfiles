#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

struct network {
  char iface[16];
  uint64_t prev_in;
  uint64_t prev_out;
  time_t prev_ts;
  bool has_prev;

  char command[256];
};

static inline bool network_interface_has_ip(struct ifaddrs* ifaddr, const char* name) {
  for (struct ifaddrs* ifa = ifaddr; ifa; ifa = ifa->ifa_next) {
    if (!ifa->ifa_name || !ifa->ifa_addr) continue;
    if (strcmp(ifa->ifa_name, name) != 0) continue;
    if (ifa->ifa_addr->sa_family == AF_INET || ifa->ifa_addr->sa_family == AF_INET6) {
      return true;
    }
  }

  return false;
}

static inline bool network_select_interface(struct network* network,
                                            struct ifaddrs* ifaddr,
                                            const char* preferred_name) {
  for (struct ifaddrs* ifa = ifaddr; ifa; ifa = ifa->ifa_next) {
    if (!ifa->ifa_name || !ifa->ifa_data) continue;
    if (strcmp(ifa->ifa_name, preferred_name) != 0) continue;
    if (!ifa->ifa_addr || ifa->ifa_addr->sa_family != AF_LINK) continue;
    if (!(ifa->ifa_flags & IFF_UP) || !(ifa->ifa_flags & IFF_RUNNING)) continue;
    if (ifa->ifa_flags & IFF_LOOPBACK) continue;
    if (!network_interface_has_ip(ifaddr, preferred_name)) continue;

    snprintf(network->iface, sizeof(network->iface), "%s", ifa->ifa_name);
    return true;
  }

  return false;
}

static inline void network_pick_interface(struct network* network) {
  struct ifaddrs* ifaddr = NULL;
  if (getifaddrs(&ifaddr) != 0) return;

  if (network_select_interface(network, ifaddr, "en0")) {
    freeifaddrs(ifaddr);
    return;
  }

  if (network_select_interface(network, ifaddr, "en1")) {
    freeifaddrs(ifaddr);
    return;
  }

  for (struct ifaddrs* ifa = ifaddr; ifa; ifa = ifa->ifa_next) {
    if (!ifa->ifa_name || !ifa->ifa_data) continue;
    if (!ifa->ifa_addr || ifa->ifa_addr->sa_family != AF_LINK) continue;
    if (!(ifa->ifa_flags & IFF_UP) || !(ifa->ifa_flags & IFF_RUNNING)) continue;
    if (ifa->ifa_flags & IFF_LOOPBACK) continue;
    if (strncmp(ifa->ifa_name, "en", 2) != 0) continue;
    if (!network_interface_has_ip(ifaddr, ifa->ifa_name)) continue;

    snprintf(network->iface, sizeof(network->iface), "%s", ifa->ifa_name);
    break;
  }

  freeifaddrs(ifaddr);
}

static inline void format_network_speed(uint64_t bytes_per_sec,
                                        char* buffer,
                                        size_t buffer_size) {
  if (bytes_per_sec < 1024) {
    snprintf(buffer, buffer_size, "%llu B", bytes_per_sec);
  } else if (bytes_per_sec < 1024 * 1024) {
    snprintf(buffer,
             buffer_size,
             "%.0f KB",
             (double)bytes_per_sec / 1024.0);
  } else {
    snprintf(buffer,
             buffer_size,
             "%.1f MB",
             (double)bytes_per_sec / (1024.0 * 1024.0));
  }
}

static inline void network_init(struct network* network) {
  network->iface[0] = '\0';
  network->prev_in = 0;
  network->prev_out = 0;
  network->prev_ts = 0;
  network->has_prev = false;
  snprintf(network->command, sizeof(network->command), "");

  network_pick_interface(network);
}

static inline void network_update(struct network* network) {
  if (network->iface[0] == '\0') network_pick_interface(network);

  struct ifaddrs* ifaddr = NULL;
  if (getifaddrs(&ifaddr) != 0) {
    snprintf(network->command, sizeof(network->command), "--set network label='--/--'");
    return;
  }

  bool found = false;
  uint64_t current_in = 0;
  uint64_t current_out = 0;

  for (struct ifaddrs* ifa = ifaddr; ifa; ifa = ifa->ifa_next) {
    if (!ifa->ifa_name || !ifa->ifa_data) continue;
    if (strcmp(ifa->ifa_name, network->iface) != 0) continue;
    if (ifa->ifa_addr && ifa->ifa_addr->sa_family != AF_LINK) continue;

    struct if_data* if_data = (struct if_data*)ifa->ifa_data;
    current_in = if_data->ifi_ibytes;
    current_out = if_data->ifi_obytes;
    found = true;
    break;
  }

  freeifaddrs(ifaddr);

  if (!found) {
    network->iface[0] = '\0';
    snprintf(network->command, sizeof(network->command), "--set network label='--/--'");
    return;
  }

  time_t now = time(NULL);

  if (!network->has_prev || now <= network->prev_ts) {
    network->prev_in = current_in;
    network->prev_out = current_out;
    network->prev_ts = now;
    network->has_prev = true;
    snprintf(network->command, sizeof(network->command), "--set network label='↓ 0KB/s ↑ 0KB/s'");
    return;
  }

  uint64_t delta_in = current_in >= network->prev_in ? current_in - network->prev_in : 0;
  uint64_t delta_out = current_out >= network->prev_out ? current_out - network->prev_out : 0;
  time_t delta_t = now - network->prev_ts;

  network->prev_in = current_in;
  network->prev_out = current_out;
  network->prev_ts = now;

  uint64_t in_per_sec = delta_t > 0 ? delta_in / delta_t : 0;
  uint64_t out_per_sec = delta_t > 0 ? delta_out / delta_t : 0;

  char in_buffer[32];
  char out_buffer[32];
  format_network_speed(in_per_sec, in_buffer, sizeof(in_buffer));
  format_network_speed(out_per_sec, out_buffer, sizeof(out_buffer));

  snprintf(network->command,
           sizeof(network->command),
           "--set network label='↓ %s ↑ %s'",
           in_buffer,
           out_buffer);
}
