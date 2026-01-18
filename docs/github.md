# github常用资料

## 常用网站链接样式写法

### 一、基础写法

1. **纯文本链接**  

```html
https://example.com
```

2. **基础锚文本**

```html
<a href="https://example.com">示例域名</a>
```

```markdown
[示例域名](https://example.com)
```

### 二、增强样式方案

#### 方案1：按钮式链接

```html
<a href="https://example.com" 
class="btn btn-primary px-4 py-2 rounded-pill shadow-sm">
<i class="bi bi-box-arrow-up-right me-2"></i>
立即访问
</a>
```

#### 方案2：卡片式链接

```html
<div class="card border-primary hover-shadow">
<div class="card-body">
<h5 class="card-title">
  <i class="bi bi-globe me-2"></i>官方网站
</h5>
<a href="https://example.com" 
   class="stretched-link text-decoration-none text-muted">
   https://example.com
</a>
</div>
</div>
```

#### 方案3：面包屑导航

```html
<nav aria-label="breadcrumb">
<ol class="breadcrumb">
<li class="breadcrumb-item">
  <a href="https://example.com">首页</a>
</li>
<li class="breadcrumb-item active">当前页</li>
</ol>
</nav>
```

### 三、高级功能实现

1. **带徽标的链接组**

```html
<div class="list-group">
<a href="https://github.com" 
 class="list-group-item list-group-item-action d-flex align-items-center">
<img src="github-icon.png" width="32" class="me-3">
GitHub 代码托管平台
<span class="badge bg-primary rounded-pill ms-auto">推荐</span>
</a>
</div>
```

2. **分页导航**

```html
<nav>
<ul class="pagination">
<li class="page-item"><a class="page-link" href="#prev">上一页</a></li>
<li class="page-item active"><a class="page-link" href="#1">1</a></li>
<li class="page-item"><a class="page-link" href="#2">2</a></li>
<li class="page-item"><a class="page-link" href="#next">下一页</a></li>
</ul>
</nav>
```

3. **链接悬浮特效**  

```css
a.hover-effect {
transition: all 0.3s ease;
position: relative;
}
a.hover-effect::after {
content: '';
position: absolute;
bottom: -2px;
left: 0;
width: 0;
height: 2px;
background: #0d6efd;
transition: width 0.3s;
}
a.hover-effect:hover::after {
width: 100%;
}
```

### 四、最佳实践建议

1. **安全增强**

```html
<a href="https://example.com" 
target="_blank" 
rel="noopener noreferrer"
referrerpolicy="strict-origin-when-cross-origin">
安全外链
</a>
```

2. **SEO优化**  

```html
<a href="https://example.com" 
aria-label="访问示例网站（新窗口打开）"
data-track-event="external_link_click">
示例网站
</a>
```

3. **响应式处理**

```html
<a href="https://m.example.com" 
class="d-block d-md-none">移动版</a>
<a href="https://example.com" 
class="d-none d-md-block">桌面版</a>
```

### 五、链接验证工具

```javascript
// 链接有效性检测
function checkLink(url) {
return fetch(url, { method: 'HEAD', mode: 'no-cors' })
.then(res => ({ status: res.ok ? 'active' : 'error' }))
.catch(() => ({ status: 'error' }));
}
```

### 6. 无障碍访问增强

```html
<a href="https://example.com" 
   aria-label="访问示例网站（将在新窗口打开）"
   title="点击访问示例网站"
   role="link">
   示例网站
</a>
```

### 7. 链接分组导航

```html
<div class="nav flex-column">
  <a href="#section1" class="nav-link">章节一</a>
  <a href="#section2" class="nav-link">章节二</a>
  <a href="#section3" class="nav-link">章节三</a>
</div>
```

## 邮箱写法

### 一、基础写法

1. **纯文本格式**  

```html
service@example.com
```

2. **可点击链接**  

```html
<a href="mailto:service@example.com">发送邮件</a>
```

```markdown
[contact@example.com](mailto:contact@example.com)
```

### 二、增强功能参数

通过URL参数实现高级功能（参数间用`&`连接）：

1. **多收件人**  

```html
<a href="mailto:admin@example.com,support@example.com">联系团队</a>
```

2. **预填信息**  

```html
<a href="mailto:sales@example.com?cc=manager@example.com&bcc=log@example.com&subject=合作咨询&body=尊敬的%20销售团队：%0A%0A请查收附件文档">
   带模板的邮件
</a>
```
*参数说明：*
- `cc=` 抄送地址
- `bcc=` 密送地址  
- `subject=` 邮件主题（空格需转义为`%20`）
- `body=` 正文内容（换行符为`%0A`）

### 三、防爬虫方案

1. **字符实体转义**  

```html
<a href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;%73%65%72%76%69%63%65%40%65%78%61%6D%70%6C%65%2E%63%6F%6D">
   安全联系
</a>
```

2. **JavaScript动态生成**  

```html
<script>
document.write('<a href="mailto:' + 
 'service' + '@' + 'example.com">联系我们</a>');
</script>
```

3. **图片显示邮箱**  

```html
<img src="email-address.png" alt="service#example.com (替换@为#)">
```

### 四、最佳实践建议

1. **移动端适配**  

```html
<a href="mailto:service@example.com" 
  class="btn btn-primary"
  style="font-size: 16px; padding: 12px 24px;">
   <i class="bi bi-envelope"></i> 立即联系
</a>
```

2. **国际化邮箱**  

```html
<a href="mailto:中文邮箱@域名.中国" dir="ltr">
  xn--fiq44n@xn--fiqs8s.xn--fiqz9s
</a>
```

3. **Fallback机制**  

```html
<a href="mailto:backup@example.com" 
  onclick="location.href='contact-form.html';return false;">
   备用联系
</a>
```

### 4. 动态邮箱解密方案

```html
<script>
  function decryptEmail(encoded) {
    return atob(encoded).split('').reverse().join('');
  }
  const email = decryptEmail('bWFpbHRvOmV4YW1wbGVAbWFpbC5jb20=');
  document.write(`<a href="${email}">联系我们</a>`);
</script>
```

### 5. 反爬虫进阶方案

```css
.email-address::after {
  content: attr(data-domain);
  unicode-bidi: bidi-override;
  direction: rtl;
}
```

```html
<span class="email-address" data-user="user" data-domain="moc.liamg@"></span>
```

## 图片写法

### 一、基础 Markdown 语法

直接在 Markdown 中使用链接包裹图片（如 GitHub README 等场景）：

```markdown
<!-- 普通静态图片 -->
![描述](图片URL)

<!-- 缩略图跳转到指定链接 -->
[![描述](缩略图URL)](目标URL)

<!-- 缩略图到高清图 -->
[![缩略图描述](缩略图URL)](高清图URL)
```

### 二、HTML 基础写法

使用 `<a>` 标签包裹 `<img>` 实现跳转：

```html
<a href="高清图URL" target="_blank">
  <img src="缩略图URL" alt="图片描述" width="200">
</a>
```

```html
<!-- 推荐完整写法 -->
<a href="高清大图.webp" 
   target="_blank"
   rel="noopener noreferrer"
   class="thumbnail-link">
  <img src="缩略图.webp" 
       alt="产品预览" 
       width="320"
       loading="lazy">
</a>
```

- `target="_blank"` 表示在新标签页打开
- `width` 控制缩略图显示尺寸

### 三、CSS 增强交互

为缩略图添加悬停效果和过渡动画：

```html
<style>
  .thumbnail {
    width: 200px;
    transition: transform 0.3s;
    cursor: pointer;
  }
  .thumbnail:hover {
    transform: scale(1.05);
  }
</style>

<a href="高清图URL">
  <img src="缩略图URL" class="thumbnail" alt="示例">
</a>
```

### 四、JavaScript 进阶实现

#### 1. 动态加载高清图
```html
<img 
  src="缩略图URL" 
  class="thumbnail" 
  onclick="loadHD(this)" 
  data-hd-src="高清图URL"
>

<script>
function loadHD(img) {
  const hdUrl = img.dataset.hdSrc;
  window.open(hdUrl, '_blank'); 
  // 或替换当前图：img.src = hdUrl;
}
</script>
```

#### 2. 预加载优化

```javascript
const thumbnails = document.querySelectorAll('.thumbnail');

thumbnails.forEach(thumb => {
  const hdUrl = thumb.dataset.hd;
  const preload = new Image();
  preload.src = hdUrl;

  thumb.addEventListener('click', () => {
    window.location.href = hdUrl;
  });
});
```

### 五、第三方库方案

使用 Lightbox 类库实现弹窗查看（需要引入对应 CSS/JS）：

```html
<!-- 使用 Fancybox 示例 -->
<a href="高清图URL" data-fancybox>
  <img src="缩略图URL" alt="demo" width="200">
</a>

<!-- 引入资源 -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fancyapps/ui@5.0/dist/fancybox/fancybox.css" />
<script src="https://cdn.jsdelivr.net/npm/@fancyapps/ui@5.0/dist/fancybox/fancybox.umd.js"></script>
```

### 六、响应式 & 懒加载

结合现代 Web 特性优化体验：

```html
<a href="高清图URL">
  <img 
    src="缩略图URL" 
    srcset="缩略图URL 480w, 高清图URL 1080w"
    sizes="(max-width: 600px) 480px, 1080px"
    loading="lazy"
    alt="响应式图片"
  >
</a>
```

### 七. 响应式图片高级实现

```html
<picture>
  <source media="(min-width: 1200px)" srcset="large.jpg">
  <source media="(min-width: 768px)" srcset="medium.jpg">
  <img src="small.jpg" alt="响应式图片" class="img-fluid">
</picture>
```

### 八. 图片性能优化

```html
<!-- WebP格式优先 -->
<img src="image.webp" 
     onerror="this.onerror=null;this.src='image.jpg'"
     alt="兼容性处理">
     
<!-- 渐进式加载 -->
<img src="placeholder.jpg" 
     data-src="actual-image.jpg" 
     class="lazyload blur-up">
```

## git使用常见语法

git重置仓库提交记录

```bash
git checkout main
git checkout --orphan temp-branch
git commit -m "Initial commit"
git branch -D main
git branch -m main
git push -f origin main
```

克隆仓库

```bash
git clone https://dev.brepo.ru/bayrepo/hestiacp.git
```

提交记录

```bash
git init                                                                                                           
git add .                                                                                                                                                    
git commit -m "first commit"  
git remote add origin git@github.com:hestiacn/docs.git
git push -u origin main
```

## 以下是 Git 常用命令的补充和分类整理，涵盖日常开发高频操作

---

### **一、配置与初始化**

1. **配置用户信息**  

```bash
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
```

2. **初始化新仓库**  

```bash
git init
```

3. **克隆远程仓库**  

```bash
git clone <仓库URL>       # 默认克隆主分支
git clone -b <分支名> <URL> # 克隆指定分支
```

---

### **二、提交与推送**

1. **提交更改**  
```bash
git add <文件名>          # 添加单个文件到暂存区
git add .                # 添加所有修改到暂存区
git commit -m "提交说明"  # 提交暂存区内容
```

2. **推送到远程仓库**  

```bash
git push origin <分支名>    # 推送到指定分支
git push -u origin main    # 首次推送并设置上游分支（后续可简写为 git push）
git push -f               # 强制推送（谨慎使用！会覆盖远程历史）
```

---

### **三、分支管理**

1. **分支操作**  
```bash
git branch                  # 查看本地分支
git branch <分支名>          # 创建新分支
git checkout <分支名>        # 切换到分支
git switch <分支名>          # 更直观的分支切换（Git 2.23+）
git merge <分支名>           # 合并指定分支到当前分支
git branch -d <分支名>       # 删除本地分支
git push origin --delete <分支名> # 删除远程分支
```

2. **变基操作（Rebase）**  

```bash
git rebase <分支名>          # 将当前分支变基到目标分支
git rebase --abort          # 终止变基并恢复原状
```

---

### **四、撤销与回退**

1. **撤销工作区修改**  

```bash
git checkout -- <文件名>     # 丢弃单个文件的修改
git restore <文件名>         # Git 2.23+ 推荐用法（同 checkout --）
```

2. **重置提交历史**  

```bash
git reset --soft HEAD^      # 撤销 commit，保留修改到暂存区
git reset --hard HEAD^      # 彻底回退到上一版本（慎用！会丢失修改）
git revert <commit-id>      # 创建新提交以撤销某次 commit
```

---

### **五、查看与对比**

1. **查看状态与日志**  

```bash
git status                 # 查看工作区/暂存区状态
git log                    # 查看提交历史
git log --oneline --graph  # 简洁版分支合并历史
git diff                   # 查看未暂存的修改
git diff --staged          # 查看已暂存的修改
```

2. **查看远程信息**  

```bash
git remote -v              # 查看远程仓库地址
git remote show origin     # 查看远程仓库详细信息
```

---

### **六、远程仓库协作**

1. **拉取与抓取更新**  

```bash
git pull origin <分支名>    # 拉取远程分支并合并（= fetch + merge）
git fetch origin           # 仅获取远程更新，不自动合并
```

2. **关联远程仓库** 

```bash
git remote add origin <URL>  # 添加远程仓库
git remote set-url origin <新URL> # 修改远程仓库地址
```

---

### **七、标签管理**

```bash
git tag                      # 查看所有标签
git tag -a v1.0 -m "版本说明" # 创建附注标签
git push origin --tags       # 推送所有标签到远程
git tag -d v1.0              # 删除本地标签
```

---

### **八、高级操作**

1. **储藏修改（Stash）**  

```bash
git stash                  # 临时保存未提交的修改
git stash pop              # 恢复最近一次储藏的内容
```

2. **清理未跟踪文件**  

```bash
git clean -fd             # 删除未跟踪的文件和目录（慎用！）
```

3. **子模块（Submodule）**  

```bash
git submodule add <URL>    # 添加子模块
git submodule update --init --recursive # 初始化并更新子模块
```

---

### **九、忽略文件**

- 创建 `.gitignore` 文件，规则示例：

```
# 忽略所有 .log 文件
*.log
# 忽略目录
/node_modules/
# 保留特定文件
!important.log
```
