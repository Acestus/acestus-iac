# Acestus Data Collection Rule Module Variables

variable "name" {
  type        = string
  description = "The name of the Data Collection Rule"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the Data Collection Rule"
}

variable "kind" {
  type        = string
  description = "The kind of the Data Collection Rule"
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows", "AgentDirectToStore", "WorkspaceTransforms"], var.kind)
    error_message = "Kind must be one of: Linux, Windows, AgentDirectToStore, WorkspaceTransforms."
  }
}

variable "description" {
  type        = string
  description = "Description of the Data Collection Rule"
  default     = ""
}

variable "data_collection_endpoint_id" {
  type        = string
  description = "The ID of the Data Collection Endpoint"
  default     = null
}

variable "data_sources" {
  type = object({
    syslog = optional(list(object({
      name           = string
      facility_names = list(string)
      log_levels     = list(string)
      streams        = optional(list(string), ["Microsoft-Syslog"])
    })), [])
    performance_counter = optional(list(object({
      name                          = string
      counter_specifiers            = list(string)
      sampling_frequency_in_seconds = number
      streams                       = optional(list(string), ["Microsoft-Perf"])
    })), [])
    windows_event_log = optional(list(object({
      name           = string
      x_path_queries = list(string)
      streams        = optional(list(string), ["Microsoft-WindowsEvent"])
    })), [])
    extension = optional(list(object({
      name               = string
      extension_name     = string
      streams            = list(string)
      extension_json     = optional(string)
      input_data_sources = optional(list(string), [])
    })), [])
    iis_log = optional(list(object({
      name            = string
      streams         = list(string)
      log_directories = optional(list(string), [])
    })), [])
    log_file = optional(list(object({
      name          = string
      streams       = list(string)
      file_patterns = list(string)
      format        = string
      settings = optional(object({
        text = object({
          record_start_timestamp_format = string
        })
      }))
    })), [])
    prometheus_forwarder = optional(list(object({
      name    = string
      streams = list(string)
      label_include_filter = optional(list(object({
        label = string
        value = string
      })), [])
    })), [])
    platform_telemetry = optional(list(object({
      name    = string
      streams = list(string)
    })), [])
    windows_firewall_log = optional(list(object({
      name    = string
      streams = list(string)
    })), [])
    data_import = optional(object({
      event_hub_data_source = optional(list(object({
        name           = string
        stream         = string
        consumer_group = optional(string)
      })), [])
    }))
  })
  description = "Data sources configuration"
  default     = {}
}

variable "destinations" {
  type = object({
    log_analytics = optional(list(object({
      name                  = string
      workspace_resource_id = string
    })), [])
    azure_monitor_metrics = optional(object({
      name = string
    }))
    storage_blob = optional(list(object({
      name               = string
      storage_account_id = string
      container_name     = string
    })), [])
    storage_table = optional(list(object({
      name               = string
      storage_account_id = string
      table_name         = string
    })), [])
    event_hub = optional(list(object({
      name         = string
      event_hub_id = string
    })), [])
    storage_blob_direct = optional(list(object({
      name               = string
      storage_account_id = string
      container_name     = string
    })), [])
    storage_table_direct = optional(list(object({
      name               = string
      storage_account_id = string
      table_name         = string
    })), [])
    event_hub_direct = optional(list(object({
      name         = string
      event_hub_id = string
    })), [])
  })
  description = "Destinations configuration"
}

variable "data_flows" {
  type = list(object({
    streams            = list(string)
    destinations       = list(string)
    transform_kql      = optional(string)
    output_stream      = optional(string)
    built_in_transform = optional(string)
  }))
  description = "Data flows configuration"
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  description = "Managed identity configuration"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Data Collection Rule"
  default     = {}
}
