---
name: remotion-video
description: |
  使用 Remotion 框架以编程方式创建视频。Remotion 让你用 React 组件定义视频内容，支持动画、字幕、音乐可视化等。
  触发词：
  - "用代码做视频"、"编程视频"、"React 视频"
  - "Remotion"、"remotion"
  - "/remotion-video"
  适用场景：
  - 程序化视频：(1) 批量生成 (2) 数据驱动（如年度总结）(3) 音乐可视化 (4) 自动字幕
  - 教程讲解视频：(5) 技术概念可视化（如 CNN、算法）(6) 分层递进讲解 (7) AI 配音教程
  - 3D 视频：(8) 产品展示/模型动画 (9) 卡通角色讲解 (10) 3D 数据可视化 (11) Logo 动画
---

# Remotion Video

用 React 以编程方式创建 MP4 视频的框架。

## 核心概念

1. **Composition** - 视频的定义（尺寸、帧率、时长）
2. **useCurrentFrame()** - 获取当前帧号，驱动动画
3. **interpolate()** - 将帧号映射到任意值（位置、透明度等）
4. **spring()** - 物理动画效果
5. **<Sequence>** - 时间轴上排列组件

## 快速开始

### 创建新项目

```bash
npx create-video@latest
```

选择模板后：

```bash
cd <project-name>
npm run dev  # 启动 Remotion Studio 预览
```

### 项目结构

```
my-video/
├── src/
│   ├── Root.tsx           # 注册所有 Composition
│   ├── HelloWorld.tsx     # 视频组件
│   └── index.ts           # 入口
├── public/                # 静态资源（音频、图片）
├── remotion.config.ts     # 配置文件
└── package.json
```

## 基础组件示例

### 最小视频组件

```tsx
import { AbsoluteFill, useCurrentFrame, useVideoConfig } from "remotion";

export const MyVideo = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();

  return (
    <AbsoluteFill style={{ backgroundColor: "white", justifyContent: "center", alignItems: "center" }}>
      <h1 style={{ fontSize: 100 }}>Frame {frame}</h1>
    </AbsoluteFill>
  );
};
```

### 注册 Composition

```tsx
// Root.tsx
import { Composition } from "remotion";
import { MyVideo } from "./MyVideo";

export const RemotionRoot = () => {
  return (
    <Composition
      id="MyVideo"
      component={MyVideo}
      durationInFrames={150}  // 5秒 @ 30fps
      fps={30}
      width={1920}
      height={1080}
    />
  );
};
```

## 动画技巧

### interpolate - 值映射

```tsx
import { interpolate, useCurrentFrame } from "remotion";

const frame = useCurrentFrame();

// 0-30帧：透明度 0→1
const opacity = interpolate(frame, [0, 30], [0, 1], {
  extrapolateRight: "clamp",  // 超出范围时钳制
});

// 位移动画
const translateY = interpolate(frame, [0, 30], [50, 0]);
```

### spring - 物理动画

```tsx
import { spring, useCurrentFrame, useVideoConfig } from "remotion";

const frame = useCurrentFrame();
const { fps } = useVideoConfig();

const scale = spring({
  frame,
  fps,
  config: { damping: 10, stiffness: 100 },
});
```

### Sequence - 时间编排

```tsx
import { Sequence } from "remotion";

<>
  <Sequence from={0} durationInFrames={60}>
    <Intro />
  </Sequence>
  <Sequence from={60} durationInFrames={90}>
    <MainContent />
  </Sequence>
  <Sequence from={150}>
    <Outro />
  </Sequence>
</>
```

## AI 语音解说集成

为视频添加 AI 语音解说，实现音视频同步。支持两种方案：

| 方案 | 优点 | 缺点 | 硬件要求 | 推荐度 |
|------|------|------|----------|--------|
| **MiniMax TTS** | 云端克隆、速度极快（<3秒）、音质优秀 | 按字符计费 | 无 | ⭐⭐⭐ 首选 |
| **Edge TTS** | 零配置、免费 | 固定音色、无法自定义 | 无 | ⭐⭐ |

### 方案选择流程

```
1. 首选 MiniMax TTS
   - 检测 API Key 是否配置
   - 测试调用是否正常（余额充足）
   - 如果成功 → 使用 MiniMax

2. MiniMax 不可用时
   → 退回 Edge TTS（使用预设音色 zh-CN-YunyangNeural）
```

---

## 方案一：MiniMax TTS（推荐）

云端 API 方案，无需本地 GPU，生成速度极快，音色克隆效果优秀。

### 配置

1. 注册 https://www.minimax.io （国际版）或 https://platform.minimaxi.com （国内版）
2. 获取 API Key
3. 在 MiniMax Audio 上传音频克隆音色，获取 voice_id

### API 差异

| 版本 | API 域名 | 说明 |
|------|----------|------|
| 国际版 | `api.minimax.io` | 推荐，稳定 |
| 国内版 | `api.minimaxi.com` | 需国内账号 |

**⚠️ 常见错误**：`api.minimax.chat` 是**错误的域名**，会返回 "invalid api key"。请确认使用上表中的正确域名。

### 生成脚本

使用 `scripts/generate_audio_minimax.py` 生成音频，支持：
- **断点续作**：已存在的音频文件自动跳过
- **实时进度**：显示生成进度，避免茫然等待
- **自动更新配置**：生成完成后自动更新 Remotion 的场景配置

```bash
# 设置环境变量
export MINIMAX_API_KEY="your_api_key"
export MINIMAX_VOICE_ID="your_voice_id"

# 运行脚本
python scripts/generate_audio_minimax.py
```

### 价格参考（2025年）

| 模型 | 价格 |
|------|------|
| speech-02-hd | ¥0.1/千字符 |
| speech-02-turbo | ¥0.05/千字符 |

### ⚠️ MiniMax TTS 踩坑经验

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| `invalid api key` | 使用了错误的 API 域名 | 国际版用 `api.minimax.io`，国内版用 `api.minimaxi.com` |
| config.ts 语法错误 `Syntax error "n"` | Python 脚本在 f-string 中用 `",\\n".join()` 产生了字面量 `\n` 而非真正换行 | 见下方「Python 生成 TypeScript 注意事项」 |
| 长时间无进度显示 | 后台执行命令看不到输出 | 前台执行脚本，或用 `tail -f` 实时查看日志 |

### Python 生成 TypeScript 注意事项

**❌ 错误写法**：在 f-string 中使用 `\n` 会产生字面量字符
```python
# 这会在生成的文件中写入字面的 \n 字符串，而非换行！
content = f'export const SCENES = [{",\\n".join(items)}];'
```

**✅ 正确写法**：分开处理字符串拼接
```python
# 先用真正的换行符拼接
scenes_content = ",\n".join(items)  # 在 f-string 外部拼接
# 再放入模板
content = f'''export const SCENES = [
{scenes_content}
];'''
```

---

## 方案二：Edge TTS

无需特殊硬件，完全免费，适合不需要克隆音色的场景。

### 安装

```bash
pip install edge-tts
```

### 推荐语音

| 语音 ID | 名称 | 风格 |
|---------|------|------|
| zh-CN-YunyangNeural | 云扬 | 专业播音腔（推荐） |
| zh-CN-XiaoxiaoNeural | 晓晓 | 温暖自然 |
| zh-CN-YunxiNeural | 云希 | 阳光少年 |

### 生成脚本

使用 `scripts/generate_audio_edge.py` 生成音频：

```bash
python scripts/generate_audio_edge.py
```

### Remotion 音频同步

```tsx
import { Audio, Sequence, staticFile } from "remotion";

// 音频配置（根据生成的时长）
const audioConfig = [
  { id: "01-intro", file: "01-intro.mp3", frames: 450 },
  { id: "02-main", file: "02-main.mp3", frames: 600 },
];

// 计算起始帧
const sceneStarts = audioConfig.reduce((acc, _, i) => {
  if (i === 0) return [0];
  return [...acc, acc[i - 1] + audioConfig[i - 1].frames];
}, [] as number[]);

// 场景渲染
{audioConfig.map((scene, i) => (
  <Sequence key={scene.id} from={sceneStarts[i]} durationInFrames={scene.frames}>
    <SceneComponent />
    <Audio src={staticFile(scene.file)} />
  </Sequence>
))}
```

---

## 教程类视频架构（场景驱动）

教程、讲解类视频的核心架构：**音频驱动场景切换**。

### 架构概览

```
音频脚本 → TTS 生成 → audioConfig.ts → 场景组件 → 视频渲染
```

关键思想：
1. **音频决定时长**：每个场景的持续时间由音频长度决定
2. **场景即章节**：一个概念 = 一个场景 = 一段音频
3. **配置即真理**：`audioConfig.ts` 是音画同步的单一数据源

### audioConfig.ts 模板

参见 `templates/audioConfig.ts`，包含：
- SceneConfig 接口定义
- SCENES 数组
- getSceneStart() 计算函数
- TOTAL_FRAMES 和 FPS 常量

### 场景切换 Hook

```tsx
import { useCurrentFrame } from "remotion";
import { SCENES } from "./audioConfig";

// 根据当前帧号返回场景索引
const useCurrentSceneIndex = () => {
  const frame = useCurrentFrame();
  let accumulated = 0;
  for (let i = 0; i < SCENES.length; i++) {
    accumulated += SCENES[i].durationInFrames;
    if (frame < accumulated) return i;
  }
  return SCENES.length - 1;
};

// 使用
const sceneIndex = useCurrentSceneIndex();
const currentScene = SCENES[sceneIndex];
```

### 主场景组件模式

```tsx
import { AbsoluteFill, Audio, Sequence, staticFile, useVideoConfig } from "remotion";
import { ThreeCanvas } from "@remotion/three";
import { SCENES, getSceneStart, TOTAL_FRAMES } from "./audioConfig";

export const TutorialVideo: React.FC = () => {
  const { width, height } = useVideoConfig();
  const sceneIndex = useCurrentSceneIndex();
  const currentScene = SCENES[sceneIndex];

  return (
    <AbsoluteFill style={{ backgroundColor: "#1a1a2e" }}>
      {/* 3D 内容 */}
      <ThreeCanvas width={width} height={height} camera={{ position: [0, 0, 4], fov: 50 }}>
        {/* 根据 sceneIndex 渲染不同场景 */}
        {sceneIndex === 0 && <Scene01Intro />}
        {sceneIndex === 1 && <Scene02Concept />}
        {sceneIndex === 2 && <Scene03Demo />}
      </ThreeCanvas>

      {/* 音频同步 - 每个场景一个 Sequence */}
      {SCENES.map((scene, idx) => (
        <Sequence key={scene.id} from={getSceneStart(idx)} durationInFrames={scene.durationInFrames}>
          <Audio src={staticFile(`audio/${scene.audioFile}`)} />
        </Sequence>
      ))}

      {/* UI 层：标题 + 进度 */}
      <div style={{ position: "absolute", top: 40, left: 0, right: 0, textAlign: "center" }}>
        <h1 style={{ color: "white", fontSize: 42 }}>教程标题</h1>
      </div>
      <div style={{ position: "absolute", bottom: 60, left: 60 }}>
        <span style={{ color: "white" }}>{currentScene?.title}</span>
      </div>
      {/* 进度条 */}
      <div style={{ position: "absolute", bottom: 30, left: 60, right: 60, height: 4, backgroundColor: "rgba(255,255,255,0.2)" }}>
        <div style={{ width: `${((sceneIndex + 1) / SCENES.length) * 100}%`, height: "100%", backgroundColor: "#3498DB" }} />
      </div>
    </AbsoluteFill>
  );
};
```

### Root.tsx 使用动态帧数

```tsx
import { Composition } from "remotion";
import { TutorialVideo } from "./TutorialVideo";
import { TOTAL_FRAMES } from "./audioConfig";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="Tutorial"
      component={TutorialVideo}
      fps={30}
      durationInFrames={TOTAL_FRAMES}  // 从 audioConfig 动态获取
      width={1920}
      height={1080}
    />
  );
};
```

### ⚠️ 教程视频踩坑经验

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 场景切换生硬 | 直接切换无过渡 | 用 spring/interpolate 添加入场动画 |
| 3D 内容与音频不同步 | 硬编码帧数 | 所有时长从 audioConfig 读取 |
| 渲染时 WebGL 崩溃 | 多个 ThreeCanvas 同时存在 | 用 sceneIndex 条件渲染，同时只有一个 3D 场景 |
| 视频太简略 | 只有一个大场景 | **一个概念 = 一个场景组件**，分层讲解 |
| 字幕遮挡场景内容 | 场景元素放在底部，与字幕重叠 | **有字幕时，所有场景内容必须限制在安全区域内（距底部至少 350px）** — 底部留给字幕专用，任何 `bottom: X` 元素的 X 值不得小于 350 |

### 场景组件设计原则

1. **单一职责**：每个场景组件只负责一个概念
2. **独立动画**：每个场景有自己的 useCurrentFrame()，动画从 0 开始
3. **延迟出现**：用 delay 参数控制元素依次出现
4. **相机适配**：不同场景可能需要不同相机位置

```tsx
// 场景组件示例
const Scene02Input: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // 入场动画
  const gridScale = spring({ frame, fps, config: { damping: 15 } });

  return (
    <group>
      <PixelGrid position={[0, 0, 0]} scale={gridScale * 1.5} />
    </group>
  );
};
```

### 相机控制器模式

```tsx
import { useThree } from "@react-three/fiber";

// ✅ 推荐写法：直接设置相机位置，避免插值导致的持续抖动
const CameraController: React.FC<{ sceneIndex: number }> = ({ sceneIndex }) => {
  const { camera } = useThree();

  const cameraSettings: Record<number, [number, number, number]> = {
    0: [0, 0, 4],      // 开场：正面
    1: [0, 0, 3],      // 输入层：靠近
    2: [-0.5, 0, 3.5], // 卷积：偏左
    3: [0, 0, 5],      // 总结：拉远全景
  };

  const target = cameraSettings[sceneIndex] || [0, 0, 4];

  // 直接设置位置，不用插值
  camera.position.set(target[0], target[1], target[2]);
  camera.lookAt(0, 0, 0);

  return null;
};
```

⚠️ **不要用 `position += (target - position) * factor` 这种写法**，永远无法精确收敛，会导致画面持续抖动。

---

## 常用功能

### 添加视频/音频

```tsx
import { Video, Audio, staticFile } from "remotion";

// 使用 public/ 目录下的文件
<Video src={staticFile("background.mp4")} />
<Audio src={staticFile("music.mp3")} volume={0.5} />

// 外部 URL
<Video src="https://example.com/video.mp4" />
```

### 添加图片

```tsx
import { Img, staticFile } from "remotion";

<Img src={staticFile("logo.png")} style={{ width: 200 }} />
```

### 参数化视频（动态数据）

```tsx
// 定义 props schema
const myCompSchema = z.object({
  title: z.string(),
  bgColor: z.string(),
});

export const MyVideo: React.FC<z.infer<typeof myCompSchema>> = ({ title, bgColor }) => {
  return (
    <AbsoluteFill style={{ backgroundColor: bgColor }}>
      <h1>{title}</h1>
    </AbsoluteFill>
  );
};

// 注册时传入默认值
<Composition
  id="MyVideo"
  component={MyVideo}
  schema={myCompSchema}
  defaultProps={{ title: "Hello", bgColor: "#ffffff" }}
  ...
/>
```

## 渲染输出

### CLI 渲染

```bash
# 渲染为 MP4
npx remotion render MyVideo out/video.mp4

# 指定编码器
npx remotion render --codec=h264 MyVideo out/video.mp4

# WebM 格式
npx remotion render --codec=vp8 MyVideo out/video.webm

# GIF
npx remotion render --codec=gif MyVideo out/video.gif

# 仅音频
npx remotion render --codec=mp3 MyVideo out/audio.mp3

# 图片序列
npx remotion render --sequence MyVideo out/frames

# 单帧静态图
npx remotion still MyVideo --frame=30 out/thumbnail.png
```

### 常用渲染参数

| 参数 | 说明 |
|------|------|
| `--codec` | h264, h265, vp8, vp9, gif, mp3, wav 等 |
| `--crf` | 质量 (0-51，越小越好，默认18) |
| `--props` | JSON 格式传入 props |
| `--scale` | 缩放因子 |
| `--concurrency` | 并行渲染数 |

## 高级功能

### 字幕 (@remotion/captions)

```bash
npm i @remotion/captions @remotion/install-whisper-cpp
npx remotion-install-whisper-cpp  # 安装 Whisper
```

```ts
import { transcribe } from "@remotion/install-whisper-cpp";

const { transcription } = await transcribe({
  inputPath: "audio.mp3",
  whisperPath: whisperCppPath,
  model: "medium",
});
```

### 播放器嵌入 Web 应用

```bash
npm i @remotion/player
```

```tsx
import { Player } from "@remotion/player";
import { MyVideo } from "./MyVideo";

<Player
  component={MyVideo}
  durationInFrames={150}
  fps={30}
  compositionWidth={1920}
  compositionHeight={1080}
  style={{ width: "100%" }}
  controls
  inputProps={{ title: "Dynamic Title" }}
/>
```

### AWS Lambda 渲染

```bash
npm i @remotion/lambda
npx remotion lambda policies role   # 设置 IAM
npx remotion lambda sites create    # 部署站点
npx remotion lambda render <site-url> MyVideo  # 渲染
```

## 3D 视频制作（@remotion/three）

### 安装

```bash
npm i three @react-three/fiber @remotion/three @types/three
```

**官方模板**（推荐新手）：

```bash
npx create-video@latest --template three
```

### 基础示例

```tsx
import { ThreeCanvas } from "@remotion/three";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { useEffect } from "react";
import { useThree } from "@react-three/fiber";

// 3D 场景组件
const My3DScene = () => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();
  const camera = useThree((state) => state.camera);

  useEffect(() => {
    camera.position.set(0, 0, 5);
    camera.lookAt(0, 0, 0);
  }, [camera]);

  const rotation = interpolate(frame, [0, durationInFrames], [0, Math.PI * 2]);
  const scale = spring({ frame, fps, config: { damping: 10, stiffness: 100 } });

  return (
    <mesh rotation={[0, rotation, 0]} scale={scale}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="royalblue" />
    </mesh>
  );
};

// 视频组件
export const My3DVideo = () => {
  const { width, height } = useVideoConfig();

  return (
    <ThreeCanvas width={width} height={height}>
      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} />
      <My3DScene />
    </ThreeCanvas>
  );
};
```

## 工作流最佳实践

### 推荐的 npm scripts 配置

```json
{
  "scripts": {
    "dev": "remotion studio",
    "audio": "python3 scripts/generate_audio.py",
    "render": "remotion render MyVideo out/video.mp4",
    "build": "npm run audio && npm run render"
  }
}
```

### 实时进度显示

```bash
# ✅ 推荐：前台执行，实时显示进度
npm run audio
npm run render
```

## 调试技巧

1. **Studio 热重载**：`npm run dev` 实时预览
2. **检查帧**：Studio 中拖动时间轴逐帧检查
3. **性能**：避免在组件内做重计算，用 `useMemo`
4. **静态文件**：放在 `public/` 目录，用 `staticFile()` 引用

## 常见问题

**Q: 视频渲染很慢？**
- 使用 `--concurrency` 增加并行数
- 降低分辨率测试：`--scale=0.5`
- 考虑 AWS Lambda 分布式渲染

**Q: 字体不显示？**
- 使用 `@remotion/google-fonts` 或本地加载
- 确保字体在渲染前已加载

**Q: 视频素材不播放？**
- 检查视频编码格式（推荐 H.264）
- 使用 `<OffthreadVideo>` 替代 `<Video>` 提升性能

## 参考资源

- 官方文档：https://remotion.dev/docs
- 模板库：https://remotion.dev/templates
- GitHub：https://github.com/remotion-dev/remotion

---

## Newsletter / Slides 视频模式

将电子报、演示稿转成有画外音的视频，核心架构：**每张投影片 = 一个 Sequence + 一段音频，动画延迟 = 声音实际出现的帧数**。

### 完整工作流

```
1. 撰写每张投影片的旁白脚本
2. TTS 生成 MP3 + SRT（字词级时间戳）
3. 解析 SRT → 得到每段台词的秒数
4. 将秒数 × 30 转成帧数，作为每个元素的 M delay
5. 投影片时长 = 对应音频时长 + 10 帧缓冲
6. 加背景音乐（volume 0.04）、动态字幕（可选）
```

### TTS + SRT 生成（Edge TTS）

```python
import asyncio

async def gen(name, text, voice="zh-TW-HsiaoChenNeural"):
    mp3 = f"public/audio/{name}.mp3"
    srt = f"public/audio/{name}.srt"
    p = await asyncio.create_subprocess_exec(
        "python3", "-m", "edge_tts",
        "--voice", voice, "--text", text,
        "--write-media", mp3, "--write-subtitles", srt,
        stdout=asyncio.subprocess.DEVNULL,
        stderr=asyncio.subprocess.DEVNULL,
    )
    await p.wait()
```

### SRT → 帧数映射

```python
import re

def parse_srt(path):
    with open(path) as f:
        content = f.read()
    entries = []
    for block in content.strip().split("\n\n"):
        lines = block.strip().split("\n")
        if len(lines) < 3: continue
        times = lines[1].split(" --> ")
        def to_s(t):
            h, m, s = t.strip().split(":")
            s, ms = s.split(",")
            return int(h)*3600 + int(m)*60 + int(s) + int(ms)/1000
        entries.append({"start": to_s(times[0]), "text": lines[2]})
    return entries

# 使用
entries = parse_srt("public/audio/nl-02-what.srt")
for e in entries:
    frame = int(e["start"] * 30)
    print(f"  {frame}f  {e['text']}")
```

### 音量规范

| 音轨 | volume 值 | 说明 |
|------|-----------|------|
| 旁白（TTS） | `1.0` | 主音轨，清晰优先 |
| 背景音乐 | `0.04` | 陪衬，不可盖过人声 |

### Scene 结构模板

```tsx
// 每张投影片的时长来自音频，不要硬编码
export const DURATIONS = [385, 678, 694, 768]; // 每张投影片的帧数

function getStart(idx: number) {
  return DURATIONS.slice(0, idx).reduce((a, b) => a + b, 0);
}

export const MyVideo: React.FC = () => {
  const scenes = [Slide1, Slide2, Slide3, Slide4];
  const audioFiles = ["s1.mp3", "s2.mp3", "s3.mp3", "s4.mp3"];

  return (
    <AbsoluteFill>
      <Audio src={staticFile("audio/background.mp3")} volume={0.04} />
      {scenes.map((Scene, i) => (
        <Sequence key={i} from={getStart(i)} durationInFrames={DURATIONS[i]}>
          <Scene />
          <Audio src={staticFile(`audio/${audioFiles[i]}`)} volume={1} />
        </Sequence>
      ))}
    </AbsoluteFill>
  );
};
```

---

## 动态图形动画 Hooks

以下三个 Hook 是投影片视频的标配，每张投影片都应加入：

### 1. Morphine 溶入效果（元素入场）

```tsx
function useMorphIn(delay = 0) {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const f = Math.max(0, frame - delay);
  const progress = spring({ frame: f, fps, config: { damping: 22, stiffness: 85, mass: 1 } });
  // ⚠️ Always include BOTH extrapolateLeft and extrapolateRight: "clamp"
  const blur    = interpolate(progress, [0, 1], [14, 0],   { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const opacity = interpolate(f, [0, 18], [0, 1],          { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const y       = interpolate(progress, [0, 1], [28, 0],   { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const scale   = interpolate(progress, [0, 1], [0.88, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  return { blur, opacity, y, scale };
}

// 包装元件
const M: React.FC<{ delay?: number; style?: React.CSSProperties; children: React.ReactNode }> = ({
  delay = 0, style = {}, children,
}) => {
  const { blur, opacity, y, scale } = useMorphIn(delay);
  return (
    <div style={{ opacity, filter: `blur(${blur}px)`, transform: `translateY(${y}px) scale(${scale})`, ...style }}>
      {children}
    </div>
  );
};
```

用法：`<M delay={91}>` — delay 设为该元素对应台词的帧数。

### 2. Glitch 字元干扰（标题入场）

```tsx
// ⚠️ 必须用 random() from remotion，不能用 Math.random()（Remotion 要求纯函数渲染）
import { random } from "remotion";

const GLITCH_CHARS = "░▒▓█▄▀■□▪◆◇○●01";

function useGlitch(text: string, startFrame: number, duration = 45) {
  const frame = useCurrentFrame();
  if (frame < startFrame || frame > startFrame + duration) return text;
  const intensity = 1 - (frame - startFrame) / duration;
  return text.split("").map((char, i) => {
    if (char === " " || char === "\n") return char;
    if (random(`g-${frame}-${i}`) < intensity * 0.35)
      return GLITCH_CHARS[Math.floor(random(`c-${frame}-${i}`) * GLITCH_CHARS.length)];
    return char;
  }).join("");
}

// 使用：在每个投影片的 h2/h1 加 Glitch
const Slide2: React.FC = () => {
  const gH2 = useGlitch("什麼是 Claude Code Channels？", 5, 30);
  return <h2>{gH2}</h2>;
};
```

### 3. Typewriter 逐字打印（CTA / 重点句）

```tsx
function useTypewriter(text: string, startFrame: number, charsPerSec = 18) {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const elapsed = Math.max(0, frame - startFrame);
  const chars = Math.floor(elapsed * (charsPerSec / fps));
  return text.slice(0, Math.min(chars, text.length));
}

// 使用（支援換行）
const Slide8: React.FC = () => {
  const typTitle = useTypewriter("AI 合作的\n新時代", 5, 8);
  return (
    <h1 style={{ whiteSpace: "pre-wrap", minHeight: "2.2em" }}>
      {typTitle}
    </h1>
  );
};
```

### 4. 透明字幕系統（不遮擋內容）

字幕根據 SRT 時間戳定位到絕對帧數，緊貼跑馬燈上方，關鍵詞高亮顯示。

```tsx
import { random } from "remotion";  // NOT Math.random

// 1. 關鍵詞列表（長詞優先，避免被短詞截斷）
const KEYWORDS = [
  "Claude Code Channels", "Claude Code", "Model Context Protocol", "MCP",
  "Telegram", "Discord", "n8n", "Jira AI Agents", "Jira", "AI Agent",
  "Anthropic", "Zapier",
].sort((a, b) => b.length - a.length);

// 2. 高亮函數（用 regex split，支持任何語言）
function highlightText(text: string): React.ReactNode {
  const escaped = KEYWORDS.map(k => k.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
  const regex = new RegExp(`(${escaped.join("|")})`, "g");
  return text.split(regex).map((part, i) =>
    KEYWORDS.includes(part)
      ? <span key={i} style={{ color: GREEN, fontWeight: 700, textShadow: "0 0 12px rgba(57,211,83,0.5)" }}>{part}</span>
      : <span key={i}>{part}</span>
  );
}

// 3. 字幕數據（絕對帧數 = 相對秒數×30 + slideStart）
type SubtitleEntry = { from: number; to: number; text: string };
const SUBTITLES: SubtitleEntry[] = [
  { from: 3,   to: 93,  text: "歡迎收看每日 AI 知識庫。" },
  { from: 92,  to: 373, text: "今天的主題是 Claude Code Channels……" },
  // ... 每條 SRT 都建立一個 entry
];

// 4. 字幕組件（放在主 Composition 頂層，不在 Sequence 內）
const Subtitle: React.FC = () => {
  const frame = useCurrentFrame();                     // 絕對帧數
  const entry = SUBTITLES.find(s => frame >= s.from && frame <= s.to);
  if (!entry) return null;

  const fadeIn  = interpolate(frame, [entry.from, entry.from + 6], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const fadeOut = interpolate(frame, [entry.to - 6, entry.to],     [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  return (
    <div style={{ position: "absolute", bottom: 58, left: 0, right: 0, display: "flex", justifyContent: "center", zIndex: 102, padding: "0 180px", pointerEvents: "none" }}>
      <div style={{
        opacity: Math.min(fadeIn, fadeOut),
        background: "rgba(13,17,23,0.78)",
        border: "1px solid rgba(57,211,83,0.15)",
        borderRadius: 6, padding: "10px 32px",
        fontFamily: MONO, fontSize: 23, color: TEXT, lineHeight: 1.55, textAlign: "center",
        maxWidth: 1560,
      }}>
        {highlightText(entry.text)}
      </div>
    </div>
  );
};

// 5. 加入主 Composition（在 Ticker 之前）
export const MyVideo: React.FC = () => (
  <AbsoluteFill>
    {/* ...scenes... */}
    <Subtitle />   {/* ← 字幕在跑馬燈上方，bottom:58px，不遮內容 */}
    <Ticker />
  </AbsoluteFill>
);
```

**關鍵規則：**
- `Subtitle` 必須放在頂層 Composition（不在 Sequence 內），這樣 `useCurrentFrame()` 返回絕對帧數
- `bottom: 58`（ticker 高度 52 + 6px 間距）
- 字幕 SRT 時間轉絕對帧：`absoluteFrame = slideStart + Math.round(srtSeconds * 30)`

### 5. 滾動新聞跑馬燈（全局）

```tsx
const TICKER_TEXT =
  "BREAKING: 標題一  ·  標題二  ·  標題三  ·  ";

const Ticker: React.FC = () => {
  const frame = useCurrentFrame();
  const PX_PER_CHAR = 15;
  const SPEED = 3;
  const textWidth = TICKER_TEXT.length * PX_PER_CHAR;
  const offset = (frame * SPEED) % textWidth;

  return (
    <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 52, zIndex: 100, overflow: "hidden", display: "flex", background: "#39d353" }}>
      {/* LIVE 標籤 */}
      <div style={{ minWidth: 120, background: "#0d1117", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <span style={{ color: "#39d353", fontWeight: 800, fontSize: 17 }}>● LIVE</span>
      </div>
      {/* 滾動文字 */}
      <div style={{ flex: 1, overflow: "hidden", display: "flex", alignItems: "center" }}>
        <div style={{ transform: `translateX(${-offset}px)`, whiteSpace: "nowrap" }}>
          <span style={{ fontSize: 20, color: "#0d1117", fontWeight: 700 }}>
            {TICKER_TEXT}{TICKER_TEXT}
          </span>
        </div>
      </div>
    </div>
  );
};

// 放在主 Composition 最後，讓它永遠在最上層
export const MyVideo: React.FC = () => (
  <AbsoluteFill>
    {/* ...scenes... */}
    <Ticker />
  </AbsoluteFill>
);
```

---

## ⚠️ 常見錯誤（已踩過）

| 錯誤 | 原因 | 解法 |
|------|------|------|
| `Expected ")" but found "key"` | 在 `.map()` 箭頭函數回傳的括號內放了 `{/* 注釋 */}` | 把注釋移到 JSX 元素**內部**，或完全刪除 |
| `Math.random()` 讓影格不確定 | Remotion 要求純函數渲染 | 改用 `random("seed-string")` from `remotion`，seed 含 frame/index 即可 |
| 背景音樂蓋過人聲 | `volume` 設太高 | 背景音樂最多 `0.07`，有旁白時用 `0.04` |
| 自製的 ffmpeg 合成音效幾乎無聲 | `aeval` 濾鏡輸出極低 | 用 `volume=2` 並加 `aecho`；產完用 `volumedetect` 驗證 |
| 字幕遮住投影片內容 | 元素定位在底部 | 有字幕時，所有內容距底部至少 350px |

---

## 投影片視頻標準設計系統

每次製作投影片視頻，預設套用以下規格：

### 視覺層級
1. **背景層**：純色或漸層 `<AbsoluteFill>`
2. **掃描線層**：`repeating-linear-gradient` 半透明條紋，加質感
3. **終端 Chrome 列**：頂部欄位（標題 + 計數器 + 交通燈）
4. **內容層**：使用 `M` 包裝，delay 對齊旁白時間
5. **全局 UI 層**：進度條、跑馬燈（zIndex 最高）

### 動畫標準
| 效果 | 用途 | 參數 |
|------|------|------|
| Morphine（useMorphIn） | 所有內容元素入場 | delay = 旁白帧数 |
| Glitch（useGlitch） | 每張投影片的標題 | startFrame=5, duration=30 |
| Typewriter（useTypewriter） | CTA 標題、重點句 | startFrame=5, charsPerSec=8-18 |
| Slide 轉場 | useSlideTransition + useSlideBlur | 4 keyframe interpolate，前後 22 幀 |
| 跑馬燈（Ticker） | 全局新聞條 | SPEED=3px/frame |

### 投影片轉場 Hook

```tsx
function useSlideTransition(total: number) {
  const frame = useCurrentFrame();
  return interpolate(frame, [0, 22, total - 22, total], [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
}

function useSlideBlur(total: number) {
  const frame = useCurrentFrame();
  return interpolate(frame, [0, 22, total - 22, total], [12, 0, 0, 12],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
}

// 每張投影片套用
const Slide1: React.FC = () => {
  const dur   = DURATIONS[0];
  const alpha = useSlideTransition(dur);
  const blur  = useSlideBlur(dur);
  return (
    <AbsoluteFill style={{ opacity: alpha, filter: `blur(${blur}px)` }}>
      {/* 內容 */}
    </AbsoluteFill>
  );
};
```

---

## 🎨 User Style Preferences (James)

**Default motion graphics style: Glassmorphism + YouTube Tutorial**

Always apply these defaults unless the user specifies otherwise:

### Component Style Rules

**Surfaces (LowerThird, Callout, ChapterCard panels):**
```tsx
background: "rgba(255,255,255,0.08)",
backdropFilter: "blur(20px)",
border: "1px solid rgba(255,255,255,0.2)",
borderRadius: 16,
boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
```

**Callout icons:** Use emoji (💡 ⚡ 📌 ✅) — friendly, not cold/corporate.

**Typography:** Rounded, warm fonts. Prefer `Inter`, `Nunito`, or `Poppins` over monospace/serif.

**Accent colors:** Bright, saturated (YouTube-style) — e.g. `#FF6B35`, `#20D9BA`, `#FFD60A`. Avoid muted/corporate palettes.

**Animations:** Spring-based entry (damping 18–22, stiffness 85–120). Blur + slide + scale on morph-in.

**Progress Bar:** Show scrubber + chapter title only. **NO timestamp (`mm:ss / mm:ss`)** — remove it.

### Quick Glassmorphism Card Template
```tsx
<div style={{
  background: "rgba(255,255,255,0.08)",
  backdropFilter: "blur(20px)",
  WebkitBackdropFilter: "blur(20px)",
  border: "1px solid rgba(255,255,255,0.18)",
  borderRadius: 20,
  padding: "16px 24px",
  boxShadow: "0 8px 32px rgba(0,0,0,0.25)",
}}>
  {/* content */}
</div>
```
