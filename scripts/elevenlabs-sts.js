#!/usr/bin/env node
// elevenlabs-sts.js <input.mp3> <output.mp3>
// ElevenLabs Speech-to-Speech：保留內容，轉換成指定聲音

const fs = require('fs');
const { ElevenLabsClient } = require('/opt/homebrew/lib/node_modules/@elevenlabs/elevenlabs-js');

const [,, inputFile, outputFile] = process.argv;
if (!inputFile || !outputFile) {
  console.error('Usage: elevenlabs-sts.js <input.mp3> <output.mp3>');
  process.exit(1);
}

const API_KEY = process.env.ELEVENLABS_API_KEY;
const VOICE_ID = process.env.ELEVENLABS_VOICE_ID || '9lHjugDhwqoxA5MhX0az';

if (!API_KEY) { console.error('Missing ELEVENLABS_API_KEY'); process.exit(1); }
if (!fs.existsSync(inputFile)) { console.error(`找不到音檔: ${inputFile}`); process.exit(1); }

async function main() {
  const client = new ElevenLabsClient({ apiKey: API_KEY });
  console.log(`[STS] 轉換中：${inputFile} → ${outputFile}`);

  const audio = await client.speechToSpeech.convert(VOICE_ID, {
    audio: fs.createReadStream(inputFile),
    modelId: 'eleven_multilingual_sts_v2',
    outputFormat: 'mp3_44100_128',
  });

  const chunks = [];
  for await (const chunk of audio) chunks.push(chunk);
  fs.writeFileSync(outputFile, Buffer.concat(chunks));
  console.log(`[STS] ✅ 完成 → ${outputFile}`);
}

main().catch(err => {
  console.error('[STS] ❌ 錯誤:', err.message);
  process.exit(1);
});
