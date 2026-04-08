# EasySteer 实验执行状态（重新运行于 2026-04-08）

按你的要求我已“重新运行”并再次验证，当前容器仍无法访问外网（不仅是 GitHub，其他站点也 403），所以无法在线克隆 EasySteer。

## 重新运行结果

- `curl -I https://github.com` -> `HTTP/1.1 403 Forbidden`
- `curl -I https://gitee.com` -> `HTTP/1.1 403 Forbidden`
- `bash scripts/run_easysteer_experiment.sh` -> 快速失败并提示无法访问 GitHub

## 这次修复了什么

我把脚本升级为**支持离线源码输入**，避免你必须依赖在线 clone：

- 新增参数 `--source PATH`，可接受：
  - 本地源码目录
  - `.tar.gz` / `.tgz`
  - `.zip`
- 当提供 `--source` 时，脚本会跳过网络 clone，直接解包/复制并继续 conda + 依赖安装流程。

## 离线跑通方法

如果你能提供 EasySteer 源码包到当前环境（例如 `/workspace/EasySteer.zip`），执行：

```bash
bash scripts/run_easysteer_experiment.sh --source /workspace/EasySteer.zip
```

如需指定环境名/目录：

```bash
bash scripts/run_easysteer_experiment.sh \
  --source /workspace/EasySteer.zip \
  --workdir /workspace/easysteer_run \
  --env-name easysteer
```

等你把源码包放进来后，我可以继续把训练/推理命令也帮你实际跑完并调参。
