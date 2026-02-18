# Acestus Data Collection Rule Module - Native Terraform
# Uses azurerm_monitor_data_collection_rule resource directly (no AVM available)

resource "azurerm_monitor_data_collection_rule" "this" {
  name                        = var.name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  kind                        = var.kind
  description                 = var.description != "" ? var.description : null
  data_collection_endpoint_id = var.data_collection_endpoint_id

  # Managed identity
  dynamic "identity" {
    for_each = var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0 ? [1] : []
    content {
      type         = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : (var.managed_identities.system_assigned ? "SystemAssigned" : "UserAssigned")
      identity_ids = length(var.managed_identities.user_assigned_resource_ids) > 0 ? var.managed_identities.user_assigned_resource_ids : null
    }
  }

  # Data sources
  dynamic "data_sources" {
    for_each = var.data_sources != null ? [var.data_sources] : []
    content {
      # Syslog
      dynamic "syslog" {
        for_each = data_sources.value.syslog != null ? data_sources.value.syslog : []
        content {
          name           = syslog.value.name
          facility_names = syslog.value.facility_names
          log_levels     = syslog.value.log_levels
          streams        = syslog.value.streams
        }
      }

      # Performance counters
      dynamic "performance_counter" {
        for_each = data_sources.value.performance_counter != null ? data_sources.value.performance_counter : []
        content {
          name                          = performance_counter.value.name
          counter_specifiers            = performance_counter.value.counter_specifiers
          sampling_frequency_in_seconds = performance_counter.value.sampling_frequency_in_seconds
          streams                       = performance_counter.value.streams
        }
      }

      # Windows Event Log
      dynamic "windows_event_log" {
        for_each = data_sources.value.windows_event_log != null ? data_sources.value.windows_event_log : []
        content {
          name           = windows_event_log.value.name
          x_path_queries = windows_event_log.value.x_path_queries
          streams        = windows_event_log.value.streams
        }
      }

      # Extension
      dynamic "extension" {
        for_each = data_sources.value.extension != null ? data_sources.value.extension : []
        content {
          name               = extension.value.name
          extension_name     = extension.value.extension_name
          streams            = extension.value.streams
          extension_json     = extension.value.extension_json
          input_data_sources = extension.value.input_data_sources
        }
      }

      # IIS Log
      dynamic "iis_log" {
        for_each = data_sources.value.iis_log != null ? data_sources.value.iis_log : []
        content {
          name            = iis_log.value.name
          streams         = iis_log.value.streams
          log_directories = iis_log.value.log_directories
        }
      }

      # Log File
      dynamic "log_file" {
        for_each = data_sources.value.log_file != null ? data_sources.value.log_file : []
        content {
          name          = log_file.value.name
          streams       = log_file.value.streams
          file_patterns = log_file.value.file_patterns
          format        = log_file.value.format

          dynamic "settings" {
            for_each = log_file.value.settings != null ? [log_file.value.settings] : []
            content {
              text {
                record_start_timestamp_format = settings.value.text.record_start_timestamp_format
              }
            }
          }
        }
      }

      # Prometheus Forwarder
      dynamic "prometheus_forwarder" {
        for_each = data_sources.value.prometheus_forwarder != null ? data_sources.value.prometheus_forwarder : []
        content {
          name    = prometheus_forwarder.value.name
          streams = prometheus_forwarder.value.streams

          dynamic "label_include_filter" {
            for_each = prometheus_forwarder.value.label_include_filter != null ? prometheus_forwarder.value.label_include_filter : []
            content {
              label = label_include_filter.value.label
              value = label_include_filter.value.value
            }
          }
        }
      }

      # Platform Telemetry
      dynamic "platform_telemetry" {
        for_each = data_sources.value.platform_telemetry != null ? data_sources.value.platform_telemetry : []
        content {
          name    = platform_telemetry.value.name
          streams = platform_telemetry.value.streams
        }
      }

      # Windows Firewall Log
      dynamic "windows_firewall_log" {
        for_each = data_sources.value.windows_firewall_log != null ? data_sources.value.windows_firewall_log : []
        content {
          name    = windows_firewall_log.value.name
          streams = windows_firewall_log.value.streams
        }
      }

      # Data Import
      dynamic "data_import" {
        for_each = data_sources.value.data_import != null ? [data_sources.value.data_import] : []
        content {
          dynamic "event_hub_data_source" {
            for_each = data_import.value.event_hub_data_source != null ? data_import.value.event_hub_data_source : []
            content {
              name           = event_hub_data_source.value.name
              stream         = event_hub_data_source.value.stream
              consumer_group = event_hub_data_source.value.consumer_group
            }
          }
        }
      }
    }
  }

  # Destinations
  destinations {
    # Log Analytics
    dynamic "log_analytics" {
      for_each = var.destinations.log_analytics != null ? var.destinations.log_analytics : []
      content {
        name                  = log_analytics.value.name
        workspace_resource_id = log_analytics.value.workspace_resource_id
      }
    }

    # Azure Monitor Metrics
    dynamic "azure_monitor_metrics" {
      for_each = var.destinations.azure_monitor_metrics != null ? [var.destinations.azure_monitor_metrics] : []
      content {
        name = azure_monitor_metrics.value.name
      }
    }

    # Storage Blob
    dynamic "storage_blob" {
      for_each = var.destinations.storage_blob != null ? var.destinations.storage_blob : []
      content {
        name               = storage_blob.value.name
        storage_account_id = storage_blob.value.storage_account_id
        container_name     = storage_blob.value.container_name
      }
    }

    # Storage Table
    dynamic "storage_table" {
      for_each = var.destinations.storage_table != null ? var.destinations.storage_table : []
      content {
        name               = storage_table.value.name
        storage_account_id = storage_table.value.storage_account_id
        table_name         = storage_table.value.table_name
      }
    }

    # Event Hub
    dynamic "event_hub" {
      for_each = var.destinations.event_hub != null ? var.destinations.event_hub : []
      content {
        name         = event_hub.value.name
        event_hub_id = event_hub.value.event_hub_id
      }
    }

    # Storage Blob Direct
    dynamic "storage_blob_direct" {
      for_each = var.destinations.storage_blob_direct != null ? var.destinations.storage_blob_direct : []
      content {
        name               = storage_blob_direct.value.name
        storage_account_id = storage_blob_direct.value.storage_account_id
        container_name     = storage_blob_direct.value.container_name
      }
    }

    # Storage Table Direct
    dynamic "storage_table_direct" {
      for_each = var.destinations.storage_table_direct != null ? var.destinations.storage_table_direct : []
      content {
        name               = storage_table_direct.value.name
        storage_account_id = storage_table_direct.value.storage_account_id
        table_name         = storage_table_direct.value.table_name
      }
    }

    # Event Hub Direct
    dynamic "event_hub_direct" {
      for_each = var.destinations.event_hub_direct != null ? var.destinations.event_hub_direct : []
      content {
        name         = event_hub_direct.value.name
        event_hub_id = event_hub_direct.value.event_hub_id
      }
    }
  }

  # Data flows
  dynamic "data_flow" {
    for_each = var.data_flows
    content {
      streams            = data_flow.value.streams
      destinations       = data_flow.value.destinations
      transform_kql      = data_flow.value.transform_kql
      output_stream      = data_flow.value.output_stream
      built_in_transform = data_flow.value.built_in_transform
    }
  }

  tags = var.tags
}
