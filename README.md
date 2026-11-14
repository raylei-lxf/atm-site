# 网站（GitHub Pages）部署说明

本文件夹是 **Agent Task Manager 官网/落地页** 的源文件（英文）。

## 文件说明

- `index.md`：落地页（产品介绍、公测状态、下载方式、客服邮箱及法律页入口）
- `privacy.md`：隐私政策（Privacy Policy）
- `terms.md`：服务条款（Terms of Service，含退款与"同设备恢复"政策）
- `_config.yml`：GitHub Pages（Jekyll + minima 主题）配置
- `README.md`：本说明（已从站点构建中排除）

## 发布步骤（约 10 分钟）

1. 在 GitHub 新建一个 **public** 仓库，例如 `atm-site`；
2. 把本文件夹中的文件上传到该仓库**根目录**（README.md 可传可不传）；
3. 仓库 **Settings → Pages → Build and deployment → Source: Deploy from a branch → Branch: main / (root)** → Save；
4. 等待 1–2 分钟，访问 `https://raylei-lxf.github.io/atm-site/` 自查：
   - 首页可打开、公测免费和下载方式可见、客服邮箱（atm-support@si-world.online）可见；
   - Privacy Policy / Terms of Service 页面可打开（顶部导航有入口）；
5. **绑定自定义域名**（Creem 审核要求，已配置）：
   - 仓库内 `CNAME` 文件 = `atm.si-world.online`；DNS 需添加记录：类型 `CNAME`、主机 `atm`、值 `raylei-lxf.github.io`；
   - GitHub 自动签发 HTTPS 证书（几分钟），在 Settings → Pages 勾选 Enforce HTTPS；
   - 对外网址统一为 `https://atm.si-world.online`，用于 Creem **Business Details 网站字段**与审核表单的“产品 URL”。

## 注意

- 公测期间免费；npm 核心包已发布，VS Code Marketplace 当前不可用，Open VSX 暂未发布。渠道状态变化时同步更新两个官网首页。
- 客服邮箱统一为 `atm-support@si-world.online`（已写入 index / privacy / terms）；若以后更换，需三处同改 + 更新 Creem 各处（Business Details / 商品描述 / Private note）；
- 条款中的"适用法律/管辖"与"消费者权利"条款已于 2026-10-09 补充（任务 #73.8）；退款与恢复政策以站内 terms.md 为准（签发前可退、签发后同设备免费恢复）；
- 客服邮箱已采用品牌邮箱 `atm-support@si-world.online`，站点使用自有域名 `atm.si-world.online`。

## 历史维护记录

- 产品服务条款已按公测免费起草；发布前应进行法律审查，法定权利不受该文案排除。
- **Marketplace 链接已临时移除**：因插件在 Marketplace 被微软暂时封禁（等待解封），`index.md` 中两处「VS Code Marketplace」超链接已临时改为纯文字（顶部 + "How it works" 第 1 步）。解封后恢复链接并 push（进度见任务 #73.2）。
- **自定义域名**：`CNAME` 文件 = `atm.si-world.online`，`_config.yml` 的 `url` 同步为 `https://atm.si-world.online`；更换域名需同步改这两处 + DNS 的 CNAME 记录 + Creem 网站字段。
- **2026-10-09 维护记录（#73.8 收尾）**：
  - `index.md`「Pricing」补充试用结束后的行为披露（看板/数据/AI 协作可用、网页端部分功能暂停——与插件内文案一致，任务 #73.15）；「Buy a license」补充退款与恢复提示；
  - `index.md`「How it works」第 3 步更新为 Creem 结账页「Device code」必填字段（设备码随订单直达，不再以邮件为主渠道）；
  - `terms.md` 新增 §7 Consumer rights、§8 Governing law & disputes；§1 补充试用结束行为与"卸载重装不重置"；§3 退款条款明晰化（签发后不可退但同设备免费恢复）；
  - `privacy.md` 更新 Device Code（结账页填写）与 IP 判定（第三方查询 + 本机 24h 缓存）描述，Sharing 节补充 license issuance 用途。
