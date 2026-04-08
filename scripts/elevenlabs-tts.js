#!/usr/bin/env node
// elevenlabs-tts.js <input.txt> <output.mp3>
// 讀取 txt 檔（跳過第一行標題），呼叫 ElevenLabs TTS，輸出 mp3

const fs = require('fs');
const path = require('path');
const { ElevenLabsClient } = require('/opt/homebrew/lib/node_modules/@elevenlabs/elevenlabs-js');

const [,, inputFile, outputFile] = process.argv;
if (!inputFile || !outputFile) {
  console.error('Usage: elevenlabs-tts.js <input.txt> <output.mp3>');
  process.exit(1);
}

const API_KEY = process.env.ELEVENLABS_API_KEY;
const VOICE_ID = process.env.ELEVENLABS_VOICE_ID || '9lHjugDhwqoxA5MhX0az';

if (!API_KEY) {
  console.error('Missing ELEVENLABS_API_KEY');
  process.exit(1);
}

// 讀取逐字稿，跳過第一行（標題）
const lines = fs.readFileSync(inputFile, 'utf8').split('\n');
const scriptText = lines.slice(1).join('\n').trim();

if (!scriptText) {
  console.error('Script content is empty after skipping title line');
  process.exit(1);
}

async function main() {
  const client = new ElevenLabsClient({ apiKey: API_KEY });

  console.log(`[TTS] 字數：${scriptText.length} 字，呼叫 ElevenLabs...`);

  const audio = await client.textToSpeech.convert(VOICE_ID, {
    text: scriptText,
    modelId: 'eleven_multilingual_v2',
    outputFormat: 'mp3_44100_128',
  });

  // 將 stream 寫入檔案
  const chunks = [];
  for await (const chunk of audio) {
    chunks.push(chunk);
  }
  fs.writeFileSync(outputFile, Buffer.concat(chunks));
  console.log(`[TTS] ✅ 完成 → ${outputFile}`);
}

main().catch(err => {
  console.error('[TTS] ❌ 錯誤:', err.message);
  process.exit(1);
});
