#!/bin/bash
# LoRA train script by @Akegarasu modify by @bdsqlsz

# Train Model | ѵ��ģʽ
model="lora" #lora��db��sdxl_lora��sdxl_db��contralnet(unfinished)

# Train data path | ����ѵ����ģ�͡�ͼƬ
pretrained_model="/home/ubuntu/stable-diffusion-webui/models/Stable-diffusion/Anything-ink.safetensors" # base model path | ��ģ·��
is_v2_model=0                             # SD2.0 model | SD2.0ģ�� 2.0ģ���� clip_skip Ĭ����Ч
v_parameterization=0 # parameterization | ������ v2 ��512�����ֱ��ʰ汾����ʹ�á�
vae=""
train_data_dir="/home/ubuntu/train2"              # train dataset path | ѵ�����ݼ�·��
reg_data_dir=""      # directory for regularization images | �������ݼ�·����Ĭ�ϲ�ʹ������ͼ��
training_comment="this LoRA model credit from bug"	# training_comment | ѵ�����ܣ�����д����������ʹ�ô����ؼ���

# Train related params | ѵ����ز���
resolution="1024,1024"  # image resolution w,h. ͼƬ�ֱ��ʣ���,�ߡ�֧�ַ������Σ��������� 64 ������
batch_size=10         # batch size
vae_batch_size=4 #vae��ʼ��ת��ͼƬ�������С��2-4�����˿�����һ��ʼ����ͼƬ����
max_train_epoches=10  # max train epoches | ���ѵ�� epoch
save_every_n_epochs=2 # sa2ve every n epochs | ÿ N �� epoch ����һ��

gradient_checkpointing=1 #�ݶȼ�飬������ɽ�Լ�Դ棬�����ٶȱ���
gradient_accumulation_steps=64 # �ݶ��ۼ�����������Ŵ�batchsize�ı���

network_dim=512   # network dim | ���� 4~128������Խ��Խ��
network_alpha=256 # network alpha | ������ network_dim ��ͬ��ֵ���߲��ý�С��ֵ���� network_dim��һ�� ��ֹ���硣Ĭ��ֵΪ 1��ʹ�ý�С�� alpha ��Ҫ����ѧϰ�ʡ�

#dropout | �׳�(Ŀǰ��lycoris�����ݣ���ʹ��lycoris�Դ�dropout)
network_dropout="0" # dropout �ǻ���ѧϰ�з�ֹ���������ϵļ���������0.1~0.3 
scale_weight_norms="1.0" #��� dropout ʹ�ã������Լ�����Ƽ�1.0
rank_dropout="0" #loraģ�Ͷ�����rank�����dropout���Ƽ�0.1~0.3��δ���Թ���
module_dropout="0" #loraģ�Ͷ�����module�����dropout(���Ƿֲ�ģ���)���Ƽ�0.1~0.3��δ���Թ���
caption_dropout_rate="0.1"

train_unet_only=0         # train U-Net only | ��ѵ�� U-Net���������������Ч����������Դ�ʹ�á�6G�Դ���Կ���
train_text_encoder_only=0 # train Text Encoder only | ��ѵ�� �ı�������

seed="1026" # reproducable seed | �����ܲ����õ����ӣ�����һ��prompt��������Ӵ���ʵõ�ѵ��ͼ�����������Դ����ؼ���

noise_offset="0.1" # noise offset | ��ѵ�����������ƫ�����������ɷǳ������߷ǳ�����ͼ��������ã��Ƽ�����Ϊ0.1
adaptive_noise_scale="0.1" #adaptive noise scale | ����Ӧ����ƫ�Ʒ�Χ
multires_noise_iterations="0" #��ֱ���������ɢ�������Ƽ�6-10,0����,��noise_offset��ͻ��ֻ�ܿ�һ��
multires_noise_discount="0" #��ֱ����������ű������Ƽ�0.1-0.3,����ص��Ļ����á�

shuffle_caption=1 # �������tokens˳��Ĭ�����á��޸�Ϊ 0 ���á�
keep_tokens=7  # keep heading N tokens when shuffling caption tokens | ��������� tokens ʱ������ǰ N �����䡣

prior_loss_weight=1 #����Ȩ�أ�0-1

# Learning rate | ѧϰ��
lr="1e-4"
unet_lr="1e-4"
text_encoder_lr="1e-5"
lr_scheduler="constant_with_warmup" # "linear", "cosine", "cosine_with_restarts", "polynomial", "constant", "constant_with_warmup"
lr_warmup_steps=500                   # warmup steps | ���� lr_scheduler Ϊ constant_with_warmup ʱ��Ҫ��д���ֵ
lr_restart_cycles=1                 # cosine_with_restarts restart cycles | �����˻��������������� lr_scheduler Ϊ cosine_with_restarts ʱ��Ч��

min_snr_gamma=0 #��С�����٤��ֵ�����ٵ�stepʱlossֵ����ѧϰЧ�����á��Ƽ�3-5��5��ԭģ�ͼ���û��̫��Ӱ�죬3��ı����ս�����޸�Ϊ0���á�
weighted_captions=1 #Ȩ�ش�꣬Ĭ��ʶ���ǩȨ�أ��﷨ͬwebui�����÷�������(abc), [abc], (abc:1.23),���ǲ����������ڼӶ��ţ������޷�ʶ��

# Merge lora and train | ������ȡ��
base_weights=""
base_weights_multiplier="1.0"

# Block weights | �ֲ�ѵ��
enable_block_weights=0 #�����ֲ�ѵ��
down_lr_weight="1,0.2,1,1,0.2,1,1,0.2,1,1,1,1" #12�㣬��Ҫ��д12�����֣�0-1.Ҳ����ʹ�ú���д����֧��sine, cosine, linear, reverse_linear, zeros���ο�д��down_lr_weight=cosine+.25 
mid_lr_weight="1"  #1�㣬��Ҫ��д1�����֣�����ͬ�ϡ�
up_lr_weight="1,1,1,1,1,1,1,1,1,1,1,1"   #12�㣬ͬ���ϡ�
block_lr_zero_threshold=0  #����ֲ�Ȩ�ز��������ֵ����ôֱ�Ӳ�ѵ����Ĭ��0��

enable_block_dim=0 #�����ֿ�dimѵ��
block_dims="64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64" #dim�ֿ飬25��
block_alphas="1,1,2,1,2,2,4,1,1,4,4,4,1,4,1,4,2,1,1,4,1,1,1,4,1"  #alpha�ֿ飬25��
conv_block_dims="32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32" #convdim�ֿ飬25��
conv_block_alphas="1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1" #convalpha�ֿ飬25��

# Output settings | �������
output_name="candy_style"           # output model name | ģ�ͱ�������
save_model_as="safetensors" # model save ext | ģ�ͱ����ʽ ckpt, pt, safetensors
mixed_precision="bf16" # bf16Ч�����õ���30ϵ�����Կ���֧�֣�Ĭ��fp16
save_precision="bf16" # bf16Ч�����õ���30ϵ�����Կ���֧�֣�Ĭ��fp16
full_fp16=0 # �뾫��ȫ��ʹ��fp16
full_bf16=1 # �뾫��ȫ��ʹ��bf16
cache_latents=1 #����Ǳ����
cache_latents_to_disk=1 #��������Ǳ�������浽���̣������´�ѵ�������ٴλ���ת�����ٶȸ���
no_half_vae=0 #��ֹ�뾫�ȣ���ֹ��ͼ���޷���mixed_precision��Ͼ��ȹ��á�

# wandb 
wandb_api_key="ed66a86e0e25e80cbf097cc6841673c8f7353969"
log_tracker_name=$output_name

# Sample output | ��ͼ
enable_sample=1 #������ͼ
sample_every_n_epochs=1 #ÿn��epoch��һ��ͼ
sample_prompts="./toml/vector.txt"
sample_sampler="euler_a"

# ��������
network_weights=""               # pretrained weights for LoRA network | ����Ҫ�����е� LoRA ģ���ϼ���ѵ��������д LoRA ģ��·����
enable_bucket=1 # arb for diff wh | ��Ͱ
min_bucket_reso=512              # arb min resolution | arb ��С�ֱ���
max_bucket_reso=1536             # arb max resolution | arb ���ֱ���
persistent_data_loader_workers=1 # persistent dataloader workers | ���ױ��ڴ棬��������ѵ������worker������ÿ�� epoch ֮���ͣ��
clip_skip=2                      # clip skip | ��ѧ һ���� 2
save_state=1 #save
resume=""

# �Ż�������
#use_8bit_adam=1 # use 8bit adam optimizer | ʹ�� 8bit adam �Ż�����ʡ�Դ棬Ĭ�����á����� 10 ϵ���Կ��޷�ʹ�ã��޸�Ϊ 0 ���á�
#use_lion=0      # use lion optimizer | ʹ�� Lion �Ż���
optimizer_type="AdamW8bit" # "adaFactor","AdamW8bit","Lion","DAdaptation",  �Ƽ����Ż���Lion���Ƽ�ѧϰ��unetlr=lr=6e-5,tenclr=7e-6
# �����Ż���"Lion8bit"(�ٶȸ��죬�ڴ����ĸ���)��"DAdaptAdaGrad"��"DAdaptAdan"(���������㷨��Ч������)��"DAdaptSGD"
# �����Ż��� Sophia(2����1.7���Դ�)��Prodigy����Ż�����������ӦDylora
d0="4e-7"


# lycoris ѵ������
enable_lycoris_train=0 # enable lycoris train | ���� LoCon ѵ�� ���ú� network_dim �� network_alpha Ӧ��ѡ���С��ֵ������ 2~16
conv_dim=8           # conv dim | ������ network_dim���Ƽ�Ϊ 4
conv_alpha=1         # conv alpha | ������ network_alpha�����Բ����� conv_dim һ�»��߸�С��ֵ
algo="loha" # algo�������ƶ�ѵ��lycorisģ�����࣬����lora(locon)��loha��IA3�Լ�lokr��dylora ��5����ѡ
dropout="0" #lycorisר��dropout

# dylora ѵ������
enable_dylora_train=0 # enable dylora train | ���� LoCon ѵ�� ���ú� network_dim �� network_alpha Ӧ��ѡ���С��ֵ������ 2~16
unit=4	#block size

# SDXL 
min_timestep="0" #��Сʱ��Ĭ��ֵ0
max_timestep="1000" #���ʱ��Ĭ��ֵ1000
bucket_reso_steps="64" #default 64,SDXL can use 32
cache_text_encoder_outputs=0 #���������ı�������������������Դ�ʹ�á������޷���shuffle����
cache_text_encoder_outputs_to_disk=0 #���������ı������������̣�����������Դ�ʹ�á������޷���shuffle����

#checkpoint train
no_token_padding=0 #�����зִ������

#sdxl_db
diffuser_xformers=0
train_text_encoder=0



# ============= DO NOT MODIFY CONTENTS BELOW | �����޸��·����� =====================
source venv/bin/activate



export HF_HOME="huggingface"
export TF_CPP_MIN_LOG_LEVEL=3

network_module="networks.lora"
extArgs=()
train_script="train_network"

if [ $no_half_vae == 1 ]; then 
  extArgs+=("--no_half_vae"); 
  mixed_precision="no";
  full_bf16=0
  full_fp16=0
fi

if [[ $model == *db ]] ; then
	if [[ $model == "db" ]] ; then 
		train_script="train_db";
		if [[ $no_token_padding -ne 0 ]]; then extArgs+=("--no_token_padding"); fi
	else 
		train_script="train";
		if [[ $diffuser_xformers -ne 0 ]]; then extArgs+=("--diffuser_xformers"); fi
		if [[ $train_text_encoder -ne 0 ]]; then extArgs+=("--train_text_encoder"); fi
	fi
	network_module=""
	network_dim=""
	network_alpha=""
	network_weights=""
	enable_block_weights=0
	enable_block_dim=0
	enable_lycoris_train=0
	enable_dylora_train=0
	unet_lr=""
	text_encoder_lr=""
	train_unet_only=0
	train_text_encoder_only=0
	training_comment=""
	prior_loss_weight=1
	network_dropout="0"
fi

if [[ $model == sdxl* ]] ; then
	train_script="sdxl_$train_script";
	if [ $cache_text_encoder_outputs -ne 0 ]; then 
  		extArgs+=("--cache_text_encoder_outputs"); 
  		enable_bucket=0
  		shuffle_caption=0
  		if [ $cache_text_encoder_outputs_to_disk -ne 0 ]; then 
  			extArgs+=("--cache_text_encoder_outputs_to_disk"); 
		fi
	fi
	
	if [ $full_bf16 -ne 0 ]; then 
  		extArgs+=("--full_bf16"); 
  		mixed_precision="bf16"
  		full_fp16=0
	fi
	
	if [ $bucket_reso_steps != "64" ]; then 
  		extArgs+=("--bucket_reso_steps=$bucket_reso_steps"); 
	fi
	
	if [ $min_timestep != "0" ]; then 
  		extArgs+=("--min_timestep=$min_timestep"); 
	fi

	if [ $max_timestep != "1000" ]; then 
  		extArgs+=("--max_timestep=$max_timestep"); 
	fi
fi

if [ $network_module ]; then extArgs+=("--network_module=$network_module"); fi

if [ $network_dim ]; then
  extArgs+=("--network_dim=$network_dim")
  if [ $network_alpha ]; then
      extArgs+=("--network_alpha=$network_alpha")
  fi
fi

if [ $unet_lr ]; then extArgs+=("--unet_lr=$unet_lr"); fi

if [ $text_encoder_lr ]; then extArgs+=("--text_encoder_lr=$text_encoder_lr"); fi

if [ $prior_loss_weight -ne 1 ]; then extArgs+=("--prior_loss_weight=$prior_loss_weight"); fi

if [ $training_comment ]; then extArgs+=("--training_comment=$training_comment"); fi

if [ $save_state ]; then extArgs+=("--save_state"); fi

if [ $resume ]; then extArgs+=("--resume=$resume"); fi

if [ $reg_data_dir ]; then extArgs+=("--reg_data_dir=$reg_data_dir"); fi

if [ $train_unet_only -ne 0 ]; then extArgs+=("--network_train_unet_only"); 
elif [ $train_text_encoder_only -ne 0 ]; then extArgs+=("--network_train_text_encoder_only"); 
fi

if [ $network_weights ]; then extArgs+=("--network_weights=$network_weights"); fi

if [ $reg_data_dir ]; then extArgs+=("--reg_data_dir=$reg_data_dir"); fi

if [ $shuffle_caption -ne 0 ]; then extArgs+=("--shuffle_caption"); fi

if [ $persistent_data_loader_workers -ne 0 ]; then extArgs+=("--persistent_data_loader_workers"); fi

if [ $weighted_captions -ne 0 ]; then extArgs+=("--weighted_captions"); fi

if [ $caption_dropout_rate != "0" ]; then extArgs+=("--caption_dropout_rate=$caption_dropout_rate"); fi

if [ $vae ]; then extArgs+=("--vae=$vae"); fi

if [ $cache_latents -ne 0 ]; then 
	extArgs+=("--cache_latents"); 
	if [ $cache_latents_to_disk -ne 0 ]; then 
		extArgs+=("--cache_latents_to_disk"); 
	fi
fi

if [ $full_fp16 -ne 0 ]; then 
  extArgs+=("--full_fp16"); 
  mixed_precision="fp16";
fi

if [ $mixed_precision != "no" ]; then 
  extArgs+=("--mixed_precision=$mixed_precision"); 
fi

if [[ $network_dropout != "0" ]]; then
  enable_lycoris=0
  extArgs+=("--network_dropout=$network_dropout"); 
  extArgs+=("--scale_weight_norms=$scale_weight_norms"); 
  if [[ $enable_dylora != "0" && $model != db* ]]; then
    extArgs+=("--network_args rank_dropout=$rank_dropout module_dropout=$module_dropout")
  fi
fi

if [ $enable_lycoris_train == 1 ]; then
  network_module="lycoris.kohya"
  extArgs+=("--network_args conv_dim=$conv_dim conv_alpha=$conv_alpha algo=$algo dropout=$dropout")

elif [ $enable_dylora_train == 1 ]; then
  network_module="networks.dylora"
  extArgs+=("--network_args unit=$unit")
  if [[ $module_dropout != "0" ]]; then
    extArgs+=("module_dropout=$module_dropout")
  fi

elif [ $enable_block_weights == 1 ]; then
  extArgs+=("--network_args down_lr_weight=$down_lr_weight mid_lr_weight=$mid_lr_weight up_lr_weight=$up_lr_weight block_lr_zero_threshold=$block_lr_zero_threshold")
  if [ $enable_block_dim == 1 ]; then
    extArgs+=("block_dims=$block_dims block_alphas=$block_alphas")
    if [ $conv_block_dims ]; then
      extArgs+=("conv_block_dims=$conv_block_dims conv_block_alphas=$conv_block_alphas")
    fi
  fi
fi

if [[ $optimizer_type == "Lion" ]] ; then
  extArgs+=("--optimizer_type=$optimizer_type" "--optimizer_args weight_decay=0.01 betas=.95,.98")

elif [[ $optimizer_type == "DAdaptation" ]] || [[ $optimizer_type == "DAdaptAdam" ]] ; then
  extArgs+=("--optimizer_type=$optimizer_type" "--optimizer_args weight_decay=0.01 decouple=True use_bias_correction=True")
  lr="1"
  unet_lr="1"
  text_encoder_lr="1"

elif [[ $optimizer_type == "DAdaptAdan" ]] || [[ $optimizer_type == "DAdaptSGD" ]] || [[ $optimizer_type == "DAdaptAdaGrad" ]]; then
  extArgs+=("--optimizer_type=$optimizer_type" "--optimizer_args weight_decay=0.01 betas=.965,.95,.98")
  lr="1"
  unet_lr="1"
  text_encoder_lr="1"
  
elif [[ $optimizer_type == "adafactor" ]]; then
  extArgs+=("--optimizer_type=$optimizer_type" "--optimizer_args scale_parameter=False warmup_init=False relative_step=False")
  
elif [[ $optimizer_type == "Prodigy" ]]; then
  extArgs+=("--optimizer_type=$optimizer_type" "--optimizer_args weight_decay=0.01 decouple=True use_bias_correction=True d_coef=1.0 d0=$d0 safeguard_warmup=True")
  lr="1"
  unet_lr="1"
  text_encoder_lr="1"
  
elif [[ $optimizer_type == *AdamW8bit ]]; then
  extArgs+=("--optimizer_type=$optimizer_type" "--optimizer_args weight_decay=0.01 is_paged=True")
  
elif [[ $optimizer_type == *Lion8bit ]]; then
  extArgs+=("--optimizer_type=$optimizer_type" "--optimizer_args weight_decay=0.01 betas=.95,.98 is_paged=True")
fi

if [[ $noise_offset != "0" ]]; then 
  extArgs+=("--noise_offset=$noise_offset"); 
  if [[ $adaptive_noise_scale != "0" ]]; then extArgs+=("--adaptive_noise_scale=$adaptive_noise_scale"); fi  
elif [[ $multires_noise_iterations != "0" ]]; then 
  extArgs+=("--multires_noise_iterations=$multires_noise_iterations"); 
  extArgs+=("--multires_noise_discount=$multires_noise_discount"); 
fi

if [[ $vae_batch_size -ne 0 ]]; then extArgs+=("--vae_batch_size=$vae_batch_size"); fi

if [[ $min_snr_gamma -ne 0 ]]; then extArgs+=("--min_snr_gamma=$min_snr_gamma"); fi

if [[ $gradient_checkpointing -ne 0 ]]; then extArgs+=("--gradient_checkpointing"); fi

if [[ $gradient_accumulation_steps -ne 0 ]]; then extArgs+=("--gradient_accumulation_steps=$gradient_accumulation_steps"); fi

if [[ $is_v2_model == 1 ]]; then
  extArgs+=("--v2");
  extArgs+=("--v_parameterization");
  extArgs+=("--scale_v_pred_loss_like_noise_pred");
else
  extArgs+=("--clip_skip=$clip_skip");
fi

if [ $wandb_api_key ]; then
  extArgs+=("--wandb_api_key=$wandb_api_key");
  extArgs+=("--log_with=wandb");
  extArgs+=("--log_tracker_name=$log_tracker_name");
fi

if [ $enable_sample == 1 ]; then
  extArgs+=("--sample_every_n_epochs=$sample_every_n_epochs");
  extArgs+=("--sample_prompts=$sample_prompts");
  extArgs+=("--sample_sampler=$sample_sampler");
fi

if [[ $enable_bucket -ne 0 ]]; then 
  extArgs+=("--enable_bucket"); 
  if [[ $min_bucket_reso != "0" ]]; 
  	then extArgs+=("--min_bucket_reso=$min_bucket_reso"); 
  fi
  if [[ $max_bucket_reso != "0" ]]; 
  	then extArgs+=("--max_bucket_reso=$max_bucket_reso"); 
  fi
fi  

accelerate launch --num_cpu_threads_per_process=8 "./sd-scripts/$train_script.py" \
  --pretrained_model_name_or_path=$pretrained_model \
  --train_data_dir=$train_data_dir \
  --output_dir="./output" \
  --logging_dir="./logs" \
  --resolution=$resolution \
  --max_train_epochs=$max_train_epoches \
  --learning_rate=$lr \
  --lr_scheduler=$lr_scheduler \
  --lr_warmup_steps=$lr_warmup_steps \
  --lr_scheduler_num_cycles=$lr_restart_cycles \
  --output_name=$output_name \
  --train_batch_size=$batch_size \
  --save_every_n_epochs=$save_every_n_epochs \
  --save_precision=$save_precision \
  --seed=$seed \
  --max_token_length=225 \
  --caption_extension=".txt" \
  --save_model_as=$save_model_as \
  --keep_tokens=$keep_tokens \
  --xformers \
  ${extArgs[@]}
