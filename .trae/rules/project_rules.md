# ZeroClaw 项目规则

## 项目概述

ZeroClaw 是一个 Rust 优先的自主 AI 代理运行时，专注于性能、效率、稳定性、可扩展性、可持续性和安全性。

- **版本**: 0.6.5
- **Rust 版本**: 1.87
- **许可证**: MIT OR Apache-2.0
- **仓库**: https://github.com/zeroclaw-labs/zeroclaw

## 技术栈

### 核心语言
- **Rust** (edition 2024) - 主要开发语言
- **Just** - 任务运行器 (类似 make)

### 主要依赖
- **tokio** - 异步运行时
- **clap** - CLI 框架
- **serde/serde_json** - 序列化
- **reqwest** - HTTP 客户端
- **matrix-sdk** - Matrix 客户端 (可选，E2EE 支持)
- **rumqttc** - MQTT 客户端 (IoT)
- **tracing** - 日志

### 前端/桌面
- **Tauri** - 桌面应用框架 (apps/tauri)
- **Slint** - 嵌入式 UI (firmware/esp32-ui)

### 固件/硬件
- **ESP32** - Rust 嵌入式 (firmware/esp32)
- **Raspberry Pi Pico** - firmware/pico
- **STM32 Nucleo** - firmware/nucleo
- **Arduino** - firmware/arduino

## 项目结构

```
zeroclaw/
├── src/                    # 主代码库
│   ├── main.rs             # CLI 入口
│   ├── lib.rs              # 模块导出
│   ├── agent/              # 代理编排循环
│   ├── channels/           # 通信渠道 (Telegram/Discord/Slack 等)
│   ├── providers/          # 模型提供商
│   ├── tools/              # 工具执行
│   ├── memory/             # 内存/向量存储
│   ├── security/           # 安全策略
│   ├── gateway/            # Webhook 服务器
│   ├── peripherals/        # 硬件外设
│   └── runtime/            # 运行时适配器
├── crates/                 # 子 crate
│   ├── robot-kit/          # 机器人控制套件
│   └── aardvark-sys/       # 系统绑定
├── apps/tauri/             # Tauri 桌面应用
├── firmware/               # 固件代码
├── k8s/zeroclaw/           # Helm 部署清单
├── docs/                   # 文档
├── .github/workflows/      # CI/CD 工作流
├── dev/                    # 开发脚本
├── scripts/                # 部署脚本
└── dist/                   # 发布包 (AUR/Scoop)
```

## 代码风格

### Rust 格式化
```bash
cargo fmt --all
cargo fmt --all -- --check  # 检查格式
```

配置文件: `rustfmt.toml`
- max_width: 100
- tab_spaces: 4
- hard_tabs: false
- edition: 2021

### Clippy 检查
```bash
cargo clippy --all-targets -- -D warnings
```

配置文件: `clippy.toml`
- cognitive-complexity-threshold: 30
- too-many-arguments-threshold: 10
- too-many-lines-threshold: 200

### 依赖检查
```bash
cargo deny check    # 依赖审计
cargo audit         # 安全漏洞检查
```

## 构建命令

### 开发构建
```bash
cargo build          # Debug 构建
cargo build --release --locked  # Release 构建
```

### 测试
```bash
cargo test           # 运行所有测试
cargo test --lib     # 仅单元测试
```

### 运行
```bash
cargo run -- <args>  # 开发运行
```

### 完整 CI 检查
```bash
./dev/ci.sh all      # 本地完整 CI
just ci              # 格式检查 + lint + 测试
```

### Just 命令
```bash
just --list          # 查看所有命令
just fmt             # 格式化
just lint            # Clippy 检查
just test            # 测试
just build           # Release 构建
just audit           # 安全审计
```

## CI/CD 流程

### GitHub Actions 工作流
- `checks-on-pr.yml` - PR 检查
- `ci-run.yml` - CI 运行
- `release-stable-manual.yml` - 稳定版发布
- `release-beta-on-push.yml` - Beta 版发布
- `pub-aur.yml` / `pub-scoop.yml` - 包发布

### CI 质量门禁
1. 格式检查 (`cargo fmt --check`)
2. Clippy 检查 (`cargo clippy`)
3. 测试 (`cargo test`)
4. 文档链接检查

## 部署配置

### Kubernetes (k3s)
位置: `k8s/zeroclaw/`

```bash
# Helm 部署
helm upgrade --install zeroclaw ./k8s/zeroclaw -n prod
```

### values.yaml 关键配置
- `replicas: 2` - 副本数
- `service.type: NodePort` - 服务类型
- `storage.className: local-storage-nvme` - 存储类
- `resources.limits.cpu: 2000m` - CPU 限制
- `resources.limits.memory: 2Gi` - 内存限制

### 常用 kubectl 命令
```bash
kubectl get pods -n prod
kubectl logs <pod> -n prod
kubectl delete pod <pod> -n prod
kubectl apply -f <manifest> -n prod
```

## 扩展点 (Trait 驱动)

实现以下 trait 来扩展功能:

- `src/providers/traits.rs` - `Provider` trait
- `src/channels/traits.rs` - `Channel` trait
- `src/tools/traits.rs` - `Tool` trait
- `src/memory/traits.rs` - `Memory` trait
- `src/observability/traits.rs` - `Observer` trait
- `src/runtime/traits.rs` - `RuntimeAdapter` trait
- `src/peripherals/traits.rs` - `Peripheral` trait

## PR 规范

### 分支策略
- 从非 `master` 分支工作
- PR 目标为 `master`
- 不直接推送到 `master`

### 提交信息
- 使用约定式提交 (Conventional Commits)
- 格式: `type(scope): description`
- 类型: feat, fix, docs, chore, test, refactor

### PR 模板
遵循 `.github/pull_request_template.md`

### 隐私规则
- 禁止提交个人数据、API 密钥、凭证
- 使用中性占位符: `user_a`, `test_user`, `example.com`
- 身份标签: `ZeroClawAgent`, `ZeroClawOperator`, `zeroclaw_user`

### 风险分级
- **低风险**: 文档/chore/仅测试更改
- **中风险**: 大多数 `src/**` 行为更改
- **高风险**: `src/security/**`, `src/runtime/**`, `src/gateway/**`, `src/tools/**`, `.github/workflows/**`

## 反模式 (禁止)

- 不要为微小便利添加重量级依赖
- 不要静默削弱安全策略
- 不要添加"以防万一"的配置/功能标志
- 不要将大规模格式化更改与功能更改混合
- 不要修改不相关模块
- 不要绕过失败检查
- 不要在重构提交中隐藏行为更改
- 不要在测试数据/示例/文档中包含个人身份信息

## 文档

- 位置: `docs/`
- i18n 支持: `docs/i18n/`
- 文档契约: `docs/contributing/docs-contract.md`

## 相关参考

- `AGENTS.md` - AI 代理指令
- `CLAUDE.md` - Claude Code 特定指令
- `docs/contributing/pr-discipline.md` - PR 规范
- `docs/contributing/change-playbooks.md` - 变更手册
