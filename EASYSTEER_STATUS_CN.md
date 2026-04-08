# EasySteer 实验执行状态（继续运行于 2026-04-08）

按你的“继续运行”要求，我继续在当前容器里做了可执行验证。

## 当前限制（仍然存在）

- 外网仍被限制：
  - `curl -I https://github.com` -> `HTTP/1.1 403 Forbidden`
  - `curl -I https://gitee.com` -> `HTTP/1.1 403 Forbidden`
- 结论：无法在线克隆 EasySteer，只能走离线源码方式。

## 这次继续运行做了什么

我把脚本进一步升级为：

1. 支持 Python 环境后端选择：`--python-env auto|conda|venv`
2. 默认 `auto`：有 conda 用 conda，没有 conda 自动回退到 venv
3. 保留 `--source` 离线源码输入（目录 / `.tar.gz` / `.tgz` / `.zip`）

## 继续运行的实际结果

我用本地 mock 源码目录做了完整演练（避免外网依赖）：

```bash
bash scripts/run_easysteer_experiment.sh \
  --source /tmp/EasySteerMock \
  --workdir /tmp/easysteer_run_test2 \
  --env-name easysteer_mock2 \
  --python-env venv
```

结果：脚本完整跑完（exit code 0），成功检测到 `train.py` 入口。

## 下一步你只需要做

把真实 EasySteer 源码包放到容器（例如 `/workspace/EasySteer.zip`），然后执行：

```bash
bash scripts/run_easysteer_experiment.sh \
  --source /workspace/EasySteer.zip \
  --workdir /workspace/easysteer_run \
  --env-name easysteer \
  --python-env auto
```

你上传后我可以继续：
- 真实安装依赖
- 跑训练/推理命令
- 定位报错并修复到可复现
