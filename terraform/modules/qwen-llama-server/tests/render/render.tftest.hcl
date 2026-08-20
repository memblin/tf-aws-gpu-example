# One run block per quant, mirroring the three real environments.

run "iq4nl_f16" {
  command = plan

  variables {
    name         = "qwen38-iq4nl-f16"
    model_file   = "Qwen3.8-27B-IQ4_NL.gguf"
    cache_type_k = "f16"
    cache_type_v = "f16"
  }

  assert {
    condition     = strcontains(output.rendered, "--model \"$MODEL_PATH\"")
    error_message = "docker run must pass the model path variable"
  }

  assert {
    condition     = strcontains(output.rendered, "MODEL_PATH=\"/models/unsloth/Qwen3.8-27B-GGUF/Qwen3.8-27B-IQ4_NL.gguf\"")
    error_message = "MODEL_PATH must point at the IQ4_NL file inside the container"
  }

  assert {
    condition     = strcontains(output.rendered, "--include \"Qwen3.8-27B-IQ4_NL.gguf\"")
    error_message = "s3 sync must be limited to this instance's quant"
  }

  assert {
    condition     = strcontains(output.rendered, "--exclude \"*\"")
    error_message = "s3 sync must exclude everything before including one file"
  }

  assert {
    condition     = strcontains(output.rendered, "--cache-type-k f16 --cache-type-v f16")
    error_message = "cache types must render as f16/f16"
  }

  assert {
    condition     = strcontains(output.rendered, "--fit off")
    error_message = "--fit must be off"
  }

  assert {
    condition     = strcontains(output.rendered, "s3://tkclabs-models/unsloth/Qwen3.8-27B-GGUF")
    error_message = "s3 source URI must be fully rendered"
  }

  assert {
    condition     = strcontains(output.rendered, "http://127.0.0.1:$PORT/health")
    error_message = "readiness must poll llama.cpp's /health endpoint"
  }

  assert {
    condition     = strcontains(output.rendered, "/proc/uptime")
    error_message = "timing must be measured from /proc/uptime, not wall clock"
  }

  assert {
    condition     = strcontains(output.rendered, "> /dev/console")
    error_message = "timing must be emitted to the serial console"
  }

  # Guards against Terraform swallowing bash syntax. If a bash `${VAR}` or a
  # curl `%{http_code}` were left unescaped the render would have failed
  # outright; these confirm the surviving bash is intact.
  assert {
    condition     = strcontains(output.rendered, "$CONTAINER") && strcontains(output.rendered, "$SECONDS")
    error_message = "bash variables must survive template rendering"
  }

  assert {
    condition     = !strcontains(output.rendered, "$${")
    error_message = "no escaped-but-unrendered template syntax may remain"
  }
}

run "q6kxl_f16" {
  command = plan

  variables {
    name         = "qwen38-q6kxl-f16"
    model_file   = "Qwen3.8-27B-UD-Q6_K_XL.gguf"
    cache_type_k = "f16"
    cache_type_v = "f16"
  }

  assert {
    condition     = strcontains(output.rendered, "MODEL_PATH=\"/models/unsloth/Qwen3.8-27B-GGUF/Qwen3.8-27B-UD-Q6_K_XL.gguf\"")
    error_message = "MODEL_PATH must point at the UD-Q6_K_XL file"
  }

  assert {
    condition     = strcontains(output.rendered, "--include \"Qwen3.8-27B-UD-Q6_K_XL.gguf\"")
    error_message = "s3 sync must be limited to UD-Q6_K_XL"
  }

  assert {
    condition     = strcontains(output.rendered, "--cache-type-k f16 --cache-type-v f16")
    error_message = "cache types must render as f16/f16"
  }

  assert {
    condition     = strcontains(output.rendered, "CONTAINER=\"qwen38-q6kxl-f16\"")
    error_message = "container name must match the environment name"
  }
}

run "q8kxl_q80" {
  command = plan

  variables {
    name         = "qwen38-q8kxl-q80"
    model_file   = "Qwen3.8-27B-UD-Q8_K_XL.gguf"
    cache_type_k = "q8_0"
    cache_type_v = "q8_0"
  }

  assert {
    condition     = strcontains(output.rendered, "MODEL_PATH=\"/models/unsloth/Qwen3.8-27B-GGUF/Qwen3.8-27B-UD-Q8_K_XL.gguf\"")
    error_message = "MODEL_PATH must point at the UD-Q8_K_XL file"
  }

  assert {
    condition     = strcontains(output.rendered, "--include \"Qwen3.8-27B-UD-Q8_K_XL.gguf\"")
    error_message = "s3 sync must be limited to UD-Q8_K_XL"
  }

  assert {
    condition     = strcontains(output.rendered, "--cache-type-k q8_0 --cache-type-v q8_0")
    error_message = "cache types must render as q8_0/q8_0"
  }
}
