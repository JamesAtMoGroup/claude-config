# GSAP 繁體中文學習資源

## 官方資源（官方為英文，但概念通用）

- 官方文件：https://gsap.com/docs/v3/
- Ease 視覺化工具：https://gsap.com/docs/v3/Eases/
- 官方 React 整合指南：https://gsap.com/resources/React/

## 繁體中文教學文章

### Medium 系列教學（最完整）

**Jay Wu 系列（入門到進階）：**
- 入門基礎：https://jaywu-fe.medium.com/%E5%85%A5%E9%96%80-gsap-%E6%95%99%E5%AD%B8-9131afdbed04
- 入門02 流程：https://jaywu-fe.medium.com/%E5%89%8D%E7%AB%AF%E7%89%B9%E6%95%88-gsap-%E6%95%99%E5%AD%B8-%E5%85%A5%E9%96%8002-6999ace48c93
- 入門03 播放控制：https://jaywu-fe.medium.com/%E5%89%8D%E7%AB%AF%E7%89%B9%E6%95%88-gsap-%E6%95%99%E5%AD%B8-%E5%85%A5%E9%96%8003-%E6%92%AD%E6%94%BE-f9d2ad9c580e

**sshane258 系列（從入門到進階）：**
- 第01篇（基礎）：https://medium.com/@sshane258/gsap-01
- 第10篇（免費插件介紹）：https://medium.com/@sshane258/%E4%BD%BF%E7%94%A8gsap%E4%BE%86%E7%82%BA%E7%B6%B2%E9%A0%81%E5%A2%9E%E6%B7%BB%E5%8B%95%E7%95%AB%E6%95%88%E6%9E%9C-10-%E5%85%8D%E8%B2%BB%E6%8F%92%E4%BB%B6%E4%BB%8B%E7%B4%B9-fdf7cb45d694

### 部落格教學

- SlimWeb 入門：https://faith.tw/blog_view.php?id=55
- 竹白記事本（GSAP3 完整介紹）：https://chupai.github.io/posts/200229_gsap3/
- 歐斯瑞（基礎到進階）：https://www.astralweb.com.tw/use-gsap-to-create-animations-and-effects/
- JohnnTsai 基礎篇：https://johnnytsai81.github.io/Plugin/15_gsap-1/
- HackMD JS 動畫製作：https://hackmd.io/@WeberChang/HJsIMGYFF

## 核心概念中文快速參考

### 基本語法

```js
// 從目前狀態動畫到目標值
gsap.to('.元素', { x: 300, duration: 1 });

// 從指定值動畫到目前狀態
gsap.from('.元素', { opacity: 0, y: 50, duration: 0.8 });

// 指定起始和結束狀態
gsap.fromTo('.元素',
  { x: -100, opacity: 0 },      // 起始狀態
  { x: 0, opacity: 1, duration: 1 } // 結束狀態
);

// 立即設定（無動畫）
gsap.set('.元素', { opacity: 0 });
```

### 常用屬性說明

| 屬性 | 說明 | 範例 |
|------|------|------|
| `x`, `y` | 水平/垂直位移（像素）| `x: 100` |
| `xPercent`, `yPercent` | 百分比位移 | `xPercent: -50` |
| `rotation` | 旋轉角度 | `rotation: 360` |
| `scale` | 縮放比例 | `scale: 1.5` |
| `opacity` | 透明度 | `opacity: 0` |
| `duration` | 動畫時間（秒）| `duration: 1` |
| `delay` | 延遲開始（秒）| `delay: 0.5` |
| `ease` | 緩動函數 | `ease: 'power2.out'` |
| `repeat` | 重複次數（-1=無限）| `repeat: -1` |
| `yoyo` | 來回播放 | `yoyo: true` |
| `stagger` | 多元素間隔時間 | `stagger: 0.1` |

### Timeline（時間軸）

```js
const tl = gsap.timeline();

// 依序播放（預設）
tl.to('.a', { x: 100 })
  .to('.b', { y: 100 })
  .to('.c', { rotation: 180 });

// 同時播放
tl.to('.a', { x: 100 })
  .to('.b', { y: 100 }, '<');  // '<' = 與上一個同時開始

// 提前 0.2 秒開始（重疊）
tl.to('.b', { y: 100 }, '-=0.2');
```

### 播放控制

```js
const tl = gsap.timeline({ paused: true });

tl.play();      // 播放
tl.pause();     // 暫停
tl.reverse();   // 反向播放
tl.restart();   // 從頭播放
tl.seek(1.5);   // 跳到 1.5 秒
tl.progress(0.5); // 跳到 50%
tl.timeScale(2);  // 2 倍速
tl.kill();      // 銷毀
```

### 緩動函數（Ease）常用推薦

```js
// 適合 UI 進場
ease: 'power2.out'   // 自然減速，最常用
ease: 'expo.out'     // 快速開始，優雅結束

// 適合互動回饋（按鈕、彈出）
ease: 'back.out(1.7)'  // 微微彈跳，有活力感

// 彈跳效果
ease: 'bounce.out'

// 彈簧感
ease: 'elastic.out(1, 0.3)'

// 線性（進度條、計數器）
ease: 'none'
```

### ScrollTrigger（滾動觸發）

```js
import { ScrollTrigger } from 'gsap/ScrollTrigger';
gsap.registerPlugin(ScrollTrigger);

gsap.to('.box', {
  x: 500,
  scrollTrigger: {
    trigger: '.box',     // 觸發元素
    start: 'top 80%',    // 元素頂部到畫面 80% 處時開始
    end: 'bottom 20%',   // 元素底部到畫面 20% 處時結束
    scrub: 1,            // 動畫跟著滾動條走（1 = 1秒延遲）
    pin: true,           // 固定元素在畫面上
    markers: true,       // 顯示除錯標記（上線前記得移除！）
    toggleActions: 'play pause resume reset',
    // 四個動作：進入 / 離開 / 從下回來 / 從上離開
  }
});
```

### React 整合

```jsx
import { useRef } from 'react';
import { gsap } from 'gsap';
import { useGSAP } from '@gsap/react';

gsap.registerPlugin(useGSAP);

function MyComponent() {
  const container = useRef(null);

  useGSAP(() => {
    // 這裡的動畫會在元件卸載時自動清除
    gsap.from('.box', { opacity: 0, y: 30, duration: 0.6 });
  }, { scope: container });

  return (
    <div ref={container}>
      <div className="box">Hello!</div>
    </div>
  );
}
```

## 學習路徑建議

1. 先熟悉 `gsap.to()` 基本語法和常用屬性
2. 學習 `gsap.timeline()` 和位置參數（`<`, `>`, `-=`, `+=`）
3. 掌握緩動函數，用 Ease Visualizer 實際感受差異
4. 練習 `stagger` 做列表動畫
5. 學 ScrollTrigger 做滾動動畫
6. React 專案用 `useGSAP` 管理動畫生命週期
7. 進階：SplitText 文字動畫、MorphSVG 形狀變換
