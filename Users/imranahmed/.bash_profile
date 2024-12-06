alias aws-adfs-reset='rm -f ~/.aws/adfs_cookies'
alias aws-adfs-login='aws-adfs-reset ; aws-adfs-ynap login --adfs-host adfs.ynap.com --session-duration 3600'


alias sandbox='ssh leg_ahmedi@sandbox-ahmedi.pm.dev.sav.nap'
alias jumphost='ssh leg_ahmedi@jumphostgw.nap'
alias fulcrum01='ssh leg_ahmedi@fulcrum01.sav.nap'
alias feeder01='ssh leg_ahmedi@feeder01.sav.nap'
alias hawking02='ssh leg_ahmedi@hawking02.sav.nap'
alias hawking01='ssh leg_ahmedi@hawking01.sav.nap'



export PATH="/usr/local/opt/openjdk@8/bin:${PATH}"
export JAVA_HOME=`/usr/libexec/java_home -v1.8`


showipof() {
  if [[ "$3" ]]; then
    region="$3"
  else
    region="eu-west-1"
  fi
  if [ $# -lt 2 ]; then
    echo "specify the application name and the environment name! example:  showipof bob dev"
  else
    local var
    var=$(aws --region "$region" --profile ynapbedev ec2 describe-instances --query "Reservations[].Instances[]" --filters "Name=tag:Name,Values=$1-$2"|jq '.[]|select(.State.Name == "running")')
    if [[ $var ]]; then
      echo "$var" |jq -r '"instanceid: " + .InstanceId + " state: " + .State.Name + " priv: " + .PrivateIpAddress + " pub: " + .PublicIpAddress'
    else
      var=$(aws --region "$region" --profile ynapbeprd ec2 describe-instances --query "Reservations[].Instances[]" --filters "Name=tag:Name,Values=$1-$2"|jq -r '.[]|select(.State.Name == "running")')
      if [[ $var ]]; then
        echo "$var" |jq -r '"instanceid: " + .InstanceId + " state: " + .State.Name + " priv: " + .PrivateIpAddress + " pub: " + .PublicIpAddress'
      else
        echo "Couldnt find VM named $1-$2"
      fi
    fi
  fi
}
  
gotovm() {
  if [[ "$3" ]]; then
    region="$3"
  else
    region="eu-west-1"
  fi
  if [[ "$4" ]]; then
    ssh_options="$4"
  fi
  if [ $# -lt 2 ]; then
    echo "specify the application name and the environment name! example: gotovm bob dev"
  else
    local var
    local count
    var=$(aws --region "$region" --profile ynapbedev ec2 describe-instances --query "Reservations[].Instances[]" --filters "Name=tag:Name,Values=$1-$2"|jq -r '.[]|select(.State.Name == "running")')
    count=$(echo "$var"|jq -r '.PrivateIpAddress'|wc -l|xargs)
    if [[ $var ]]; then
      if [ "$count" -gt 1 ]; then
        echo -e "\nMultiple match found. Connecting to $(echo "$var"|jq -r '.PrivateIpAddress'|head -1)."
        echo -e "Use \"showipof $1 $2\" to see all the other IPs and ssh to the ip directly!\n\n"
        if [ -n "$ssh_options" ]; then
          ssh -l ec2-user "$ssh_options" -o StrictHostKeyChecking=no $(echo "$var" |jq -r '.PrivateIpAddress'|head -1)
        else
          ssh -l ec2-user -o StrictHostKeyChecking=no $(echo "$var" |jq -r '.PrivateIpAddress'|head -1)
        fi
      else
        if [ -n "$ssh_options" ]; then
          ssh -l ec2-user "$ssh_options" -o StrictHostKeyChecking=no $(echo "$var" |jq -r '.PrivateIpAddress')
        else
          ssh -l ec2-user -o StrictHostKeyChecking=no $(echo "$var" |jq -r '.PrivateIpAddress')
        fi
      fi
    else
      var=$(aws --region "$region" --profile ynapbeprd ec2 describe-instances --query "Reservations[].Instances[]" --filters "Name=tag:Name,Values=$1-$2"|jq -r '.[]|select(.State.Name == "running")') || echo "No ynapbeprd profile maybe?"
      local count
      count=$(echo "$var"|jq -r '.PrivateIpAddress'|wc -l|xargs)
      if [[ $var ]]; then
        if [ "$count" -gt 1 ]; then
          echo -e "\nMultiple match found. Connecting to $(echo "$var"|jq -r '.PrivateIpAddress'|head -1)."
          echo -e "Use \"showipof $1 $2\" to see all the other IPs and ssh to the ip directly!\n\n"
          if [ -n "$ssh_options" ]; then
            ssh -l ec2-user "$ssh_options" -o StrictHostKeyChecking=no $(echo "$var" |jq -r '.PrivateIpAddress'|head -1)
          else
            ssh -l ec2-user -o StrictHostKeyChecking=no $(echo "$var" |jq -r '.PrivateIpAddress'|head -1)
          fi
        else
          if [ -n "$ssh_options" ]; then
            ssh -l ec2-user "$ssh_options" -o StrictHostKeyChecking=no $(echo "$var" |jq -r '.PrivateIpAddress')
          else
            ssh -l ec2-user -o StrictHostKeyChecking=no $(echo "$var" |jq -r '.PrivateIpAddress')
          fi
        fi
      else
        echo "Couldnt find VM named $1-$2"
      fi
    fi
  fi
}
 
  
showallvms() {
  if [[ ! $1 ]]; then
    profile="ynapbedev"
  else
    profile="$1"
  fi
  if [[ ! $2 ]]; then
    region="eu-west-1"
  else
    region="$2"
  fi
  aws --region "$region" --profile "$profile"  ec2 describe-instances --query "Reservations[].Instances[]" |jq '.[]' | jq -r '"instanceid: " + .InstanceId + " state: " + .State.Name + " priv: " + .PrivateIpAddress + " pub: " + .PublicIpAddress'
}
