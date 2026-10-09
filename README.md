# 网站（GitHub Pages）部署说明

本文件夹是 **Agent Task Manager 官网/落地页** 的源文件（英文），用于满足 Creem 账号审核要求：产品可看懂、价格可见、隐私政策 + 服务条款、客服邮箱可见。

## 文件说明

- `index.md`：落地页（产品介绍 + 功能 + $10 定价 + 购买链接 + 客服邮箱 + 法律页入口）
- `privacy.md`：隐私政策（Privacy Policy）
- `terms.md`：服务条款（Terms of Service，含退款与"同设备恢复"政策）
- `_config.yml`：GitHub Pages（Jekyll + minima 主题）配置
- `README.md`：本说明（已从站点构建中排除）

## 发布步骤（约 10 分钟）

1. 在 GitHub 新建一个 **public** 仓库，例如 `atm-site`；
2. 把本文件夹中的文件上传到该仓库**根目录**（README.md 可传可不传）；
3. 仓库 **Settings → Pages → Build and deployment → Source: Deploy from a branch → Branch: main / (root)** → Save；
4. 等待 1–2 分钟，访问 `https://raylei-lxf.github.io/atm-site/` 自查：
   - 首页可打开、价格 $10.00 可见、客服邮箱（raylei483@gmail.com）可见；
   - Privacy Policy / Terms of Service 页面可打开（顶部导航有入口）；
5. **绑定自定义域名**（Creem 审核要求，已配置）：
   - 仓库内 `CNAME` 文件 = `atm.raylei.online`；DNS 需添加记录：类型 `CNAME`、主机 `atm`、值 `raylei-lxf.github.io`；
   - GitHub 自动签发 HTTPS 证书（几分钟），在 Settings → Pages 勾选 Enforce HTTPS；
   - 对外网址统一为 `https://atm.raylei.online`，用于 Creem **Business Details 网站字段**与审核表单的“产品 URL”。

## 注意

- 站点必须**公开可访问**（不要加密码、不要用私密仓库），审核期间保持在线；
- 购买链接已填为商品 payment link（`https://www.creem.io/payment/prod_3YHm3gjsPCnNQS6GvEaiq0`）；**账号审核通过前打开会显示 "Live payments are not enabled"，属正常现象**（发布后可再用商品 Share → Copy payment link 核对一次）；
- 客服邮箱统一为 `raylei483@gmail.com`（已写入 index / privacy / terms）；若以后更换，需三处同改 + 更新 Creem 各处（Business Details / 商品描述 / Private note）；
- 条款中的"适用法律/管辖"与"消费者权利"条款已于 2026-10-09 补充（任务 #73.8）；退款与恢复政策以站内 terms.md 为准（签发前可退、签发后同设备免费恢复）；
- 官方偏好“品牌邮箱”（如 support@yourdomain.com），当前用 Gmail 属可接受的过渡方案；若审核要求更换，可升级为域名邮箱（本站已切换到自有域名 atm.raylei.online）。

## 维护须知（2026-10-03）

- **价格单点化**：网站上的价格统一引用 `_config.yml` 的 `price_usd`（当前 `"10.00"`）。以后改价 = 改 `_config.yml` 一处 + Creem 商品 Price 字段 + push，页面显示自动跟随（外观不变）。
- **Marketplace 链接已临时移除**：因插件在 Marketplace 被微软暂时封禁（等待解封），`index.md` 中两处「VS Code Marketplace」超链接已临时改为纯文字（顶部 + "How it works" 第 1 步）。解封后恢复链接并 push（进度见任务 #73.2）。
- **自定义域名**：`CNAME` 文件 = `atm.raylei.online`，`_config.yml` 的 `url` 同步为 `https://atm.raylei.online`；更换域名需同步改这两处 + DNS 的 CNAME 记录 + Creem 网站字段。
- **2026-10-09 维护记录（#73.8 收尾）**：
  - `index.md`「Pricing」补充试用结束后的行为披露（看板/数据可用、AI 协作暂停——与插件内文案一致）；「Buy a license」补充退款与恢复提示；
  - `index.md`「How it works」第 3 步更新为 Creem 结账页「Device code」必填字段（设备码随订单直达，不再以邮件为主渠道）；
  - `terms.md` 新增 §7 Consumer rights、§8 Governing law & disputes；§1 补充试用结束行为与"卸载重装不重置"；§3 退款条款明晰化（签发后不可退但同设备免费恢复）；
  - `privacy.md` 更新 Device Code（结账页填写）与 IP 判定（第三方查询 + 本机 24h 缓存）描述，Sharing 节补充 license issuance 用途。
