# Terraform: AWS GPU Examples

I use these envs and the shared module in combination with my base enviornment
configuration, not included, which provides S3 bucktes and IAM policies / roles
that allow these modules to work.

I share them here as an example of what can be done.

## Environments Included

| Environment Name | Description |
| --- | --- |
| qwen38-iq4nl-f16 | Qwen3.8-27B IQ4_NL with f16 key cache in llama.cpp |
| qwen38-q6kxl-f16 | Qwen3.8-27B Q6_K_XL with f16 key cache in llama.cpp |
| qwen38-q8kxl-q80 | Qwen3.8-27B Q8_K_XL with q8_0 key cache in llama.cpp |

> [!TIP]
> All of these run on the g6e.xlarge by default

