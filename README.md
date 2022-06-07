# devops-netology
Hello World!

# Будут игорироваться все скрытые директории .terraform. и файлы внутри, в корне или в суб-директориях
**/.terraform/*

# Будут игнорироваться в корне все файлы с расширением tfstate, а так же файлы с конструкцией .tfstate. в сереидине
*.tfstate
*.tfstate.*

# Будут игнорироваться в корне: файл crash.log, а так же файлы crash.*.log
crash.log
crash.*.log

# Будут игнорироваться в корне все файлы, заканчивающиеся на *.tfvars или *.tfvars.json
*.tfvars
*.tfvars.json

# Будет игнорироваться в корне файл override.tf, файл override.tf.json
# Будут так же игнорироваться в корне файлы заканчивающиеся на _override.tf _override.tf.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Будет игнорироваться в корне скрытый файл .terraformrc и файл terraform.rc
.terraformrc
terraform.rc
