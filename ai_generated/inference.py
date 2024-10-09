import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from exllamav2 import ExLlamaV2, ExLlamaV2Config, ExLlamaV2Cache, ExLlamaV2Tokenizer, Timer
from exllamav2.generator import ExLlamaV2DynamicGenerator

model_dir = "/media/sam/New Volume/AIModels/llama3.1-8b-instruct"
#model_dir = "/media/sam/New Volume/AIModels/turboderp_Llama-3-8B-Instruct-exl2_4.0bpw"
config = ExLlamaV2Config(model_dir)
config.arch_compat_overrides()
model = ExLlamaV2(config)
cache = ExLlamaV2Cache(model, max_seq_len = 32768, lazy = True)
model.load_autosplit(cache, progress = True)

print("Loading tokenizer...")
tokenizer = ExLlamaV2Tokenizer(config)

# Initialize the generator with all default parameters

generator = ExLlamaV2DynamicGenerator(
    model = model,
    cache = cache,
    tokenizer = tokenizer,
    decode_special_tokens = True 
)

max_new_tokens = 4096

# Warmup generator. The function runs a small completion job to allow all the kernels to fully initialize and
# autotune before we do any timing measurements. It can be a little slow for larger models and is not needed
# to produce correct output.

generator.warmup()

def convert_openai_to_llama31(openai_prompt):
    llama_prompt = "<|begin_of_text|>"
    
    # Role mapping for llama3.1 prompt format
    role_map = {
        "system": "system",
        "user": "user",
        "assistant": "assistant",
        "ipython": "ipython"  # In case you need ipython role in the future
    }
    
    for message in openai_prompt:
        role = message.get("role", "")
        content = message.get("content", "")
        
        # Convert OpenAI roles to llama3.1 format
        llama_prompt += f"<|start_header_id|>{role_map.get(role, 'user')}<|end_header_id|>\n\n"
        llama_prompt += f"{content}\n<|eot_id|>"
    
    llama_prompt += "<|start_header_id|>assistant<|end_header_id|>\n\n"

    return llama_prompt

def tryMessages(messages):
    llama31_prompt = convert_openai_to_llama31(messages)
    output = generator.generate(prompt = llama31_prompt, max_new_tokens = max_new_tokens, add_bos = True, completion_only = True, stop_conditions =  [tokenizer.single_id("<|eot_id|>")])
    return output

def tryMessageBatch(batch):
    prompts = []
    for prompt in batch:
        prompts.append(convert_openai_to_llama31(prompt))
    outputs = generator.generate(prompt = prompts, max_new_tokens = max_new_tokens, add_bos = True, completion_only = True, stop_conditions =  [tokenizer.single_id("<|eot_id|>")])
    return outputs
