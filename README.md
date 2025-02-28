# NATScript
NAT端口转发Shell 脚本
一个用于管理 NAT端口转发 的 Shell 脚本，支持 添加、删除、列出、保存规则 功能，并包含交互式菜单
## 使用方法
获取脚本并赋予执行权限：
```
https://cdn.jsdelivr.net/gh/muzihuaner/NATScript@main/nat-manager.sh && chmod +x nat-manager.sh
```
## 交互式菜单
```
./nat-manager.sh menu

# 添加规则
./nat-manager.sh add

# 删除规则
./nat-manager.sh del

# 列出规则
./nat-manager.sh list

# 保存规则
./nat-manager.sh save
```
## 功能说明
- 自动校验输入：检查IP和端口格式有效性

- 规则持久化：通过 netfilter-persistent 保存规则（需提前安装）

- 清晰列表：列出所有DNAT规则并编号，便于删除

- 灵活配置：可修改脚本开头的 PUBLIC_IF 和 PRIVATE_NET 变量

## 注意事项
确保已安装 iptables-persistent：
```
apt install iptables-persistent -y
```
若需要允许流量转发，确保已开启IP转发并配置防火墙：
```
echo 1 > /proc/sys/net/ipv4/ip_forward
ufw default allow FORWARD
```
修改脚本中的网络接口名称（如 eno1、vmbr1）以匹配你的实际环境。

