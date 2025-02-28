#!/bin/bash

# 默认配置（根据你的需求修改）
PUBLIC_IF="eno1"       # 公网接口名称
PRIVATE_NET="vmbr0"    # 内网网桥名称
IPTABLES_SAVE_CMD="netfilter-persistent save"  # 持久化保存命令

# 临时文件记录规则
RULES_FILE="/tmp/dnat_rules.txt"

# 帮助信息
usage() {
  echo "用法: $0 [选项]"
  echo "选项:"
  echo "  add    添加端口转发规则"
  echo "  del    删除端口转发规则"
  echo "  list   列出所有规则"
  echo "  save   保存规则到持久化存储"
  echo "  menu   进入交互式菜单"
  exit 1
}

# 添加规则
add_rule() {
  read -p "请输入外部端口 (例如 80): " EXT_PORT
  read -p "请输入内部IP (例如 192.168.100.2): " DEST_IP
  read -p "请输入内部端口 (例如 80): " DEST_PORT

  # 校验输入格式
  if ! [[ $EXT_PORT =~ ^[0-9]+$ ]] || ! [[ $DEST_PORT =~ ^[0-9]+$ ]]; then
    echo "错误：端口必须是数字！"
    exit 1
  fi

  if ! [[ $DEST_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "错误：IP地址格式无效！"
    exit 1
  fi

  # 添加DNAT规则
  iptables -t nat -A PREROUTING -i $PUBLIC_IF -p tcp --dport $EXT_PORT -j DNAT --to $DEST_IP:$DEST_PORT
  iptables -A FORWARD -i $PUBLIC_IF -o $PRIVATE_NET -p tcp --dport $DEST_PORT -d $DEST_IP -j ACCEPT

  echo "规则已添加：公网端口 $EXT_PORT => $DEST_IP:$DEST_PORT"
}

# 删除规则
del_rule() {
  list_rules
  read -p "请输入要删除的规则编号: " RULE_NUM

  # 获取规则内容
  RULE=$(sed -n "${RULE_NUM}p" $RULES_FILE)
  if [ -z "$RULE" ]; then
    echo "错误：无效的规则编号！"
    exit 1
  fi

  # 解析规则参数
  EXT_PORT=$(echo $RULE | awk '{print $3}')
  DEST_IP_PORT=$(echo $RULE | awk '{print $6}')
  DEST_IP=${DEST_IP_PORT%:*}
  DEST_PORT=${DEST_IP_PORT#*:}

  # 删除规则
  iptables -t nat -D PREROUTING -i $PUBLIC_IF -p tcp --dport $EXT_PORT -j DNAT --to $DEST_IP:$DEST_PORT
  iptables -D FORWARD -i $PUBLIC_IF -o $PRIVATE_NET -p tcp --dport $DEST_PORT -d $DEST_IP -j ACCEPT

  echo "规则已删除：$RULE"
}

# 列出所有规则
list_rules() {
  echo "当前DNAT规则列表："
  echo "----------------------------------------"
  iptables -t nat -L PREROUTING -n --line-number | grep DNAT | grep "dpt:" > $RULES_FILE
  cat $RULES_FILE | nl -v 1
  echo "----------------------------------------"
}

# 保存规则
save_rules() {
  echo "正在保存规则..."
  eval $IPTABLES_SAVE_CMD
}

# 交互式菜单
show_menu() {
  while true; do
    echo ""
    echo "===== DNAT 端口转发管理菜单 ====="
    echo "1. 添加端口转发规则"
    echo "2. 删除端口转发规则"
    echo "3. 列出所有规则"
    echo "4. 保存规则到持久化存储"
    echo "5. 退出"
    read -p "请输入选项 [1-5]: " CHOICE

    case $CHOICE in
      1) add_rule ;;
      2) del_rule ;;
      3) list_rules ;;
      4) save_rules ;;
      5) exit 0 ;;
      *) echo "无效选项！" ;;
    esac
  done
}

# 主逻辑
case $1 in
  add) add_rule ;;
  del) del_rule ;;
  list) list_rules ;;
  save) save_rules ;;
  menu) show_menu ;;
  *) usage ;;
esac
