# 远程目录同步工具

这个工具用于同步远程主机的目录到本地，并在同步完成后发送webhook通知。

## 文件说明

- `sync_data.sh`: 同步脚本
- `.env.example`: 环境变量配置模板
- `README.md`: 使用说明文档

## 使用前准备

1. 配置环境变量：
   - 复制 `.env.example` 文件为 `.env`：
   ```bash
   cp .env.example .env
   ```
   - 编辑 `.env` 文件，设置以下配置：
     - WEBHOOK_URL：webhook通知地址（飞书机器人）
     - REMOTE_HOST：远程主机地址
     - REMOTE_USER：远程用户名
     - REMOTE_DIR：远程目录路径
     - LOCAL_DIR：本地目录路径
     - SSH_PORT：SSH 端口号（默认 22）

2. 添加执行权限：
```bash
chmod +x sync_data.sh
```

## 使用方法

在项目目录下运行：
```bash
./sync_data.sh
```

## 功能特点

- 使用rsync进行高效的目录同步
- 同步完成后自动发送飞书webhook通知
- 错误处理和状态报告
- 详细的日志输出
- 使用 .env 文件管理配置，更安全和灵活

## 注意事项

1. 确保本地机器有足够的存储空间
2. 确保有远程主机的SSH访问权限
3. 建议定期运行同步任务，可以使用crontab设置定时任务
4. 不要将 `.env` 文件提交到版本控制系统中
5. 对于大文件传输，脚本不使用压缩选项以提高传输速度 