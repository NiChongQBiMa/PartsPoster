import processing.sound.*;

// 资源
PImage bgImg;
SoundFile bgm;
SoundFile clickSfx;

// 中文字体
PFont titleFont;
PFont btnFont;
PFont tipFont;

// 唱片
float vinylAngle = 0;
float vinylX, vinylY;
float vinylR = 45;
boolean musicPlaying = true;

// 按钮
float btnW = 180, btnH = 60;
float clawBtnX, clawBtnY;
float clawV2BtnX, clawV2BtnY;
color btnColor = color(60, 60, 60, 200);
color btnHover = color(100, 100, 100, 220);
color btnText = color(255);

// 标题
String title = "零部件电子海报";
float titleY;

void setup() {
  size(1000, 700);
  
  // 加载中文字体（Windows 系统字体）
  titleFont = createFont("Microsoft YaHei", 42, true);
  btnFont = createFont("Microsoft YaHei", 22, true);
  tipFont = createFont("Microsoft YaHei", 12, true);
  
  // 加载资源
  bgImg = loadImage("BG.jpg");
  bgm = new SoundFile(this, "BGM.mp3");
  clickSfx = new SoundFile(this, "Sd1.wav");
  
  // 设置音量为50%，循环播放
  bgm.amp(0.5);
  bgm.loop();
  
  // 按钮位置：居中偏下
  float centerX = width / 2;
  float btnGap = 40;
  float btnCenterY = height * 0.55;
  clawBtnX = centerX - btnW - btnGap / 2;
  clawBtnY = btnCenterY - btnH / 2;
  clawV2BtnX = centerX + btnGap / 2;
  clawV2BtnY = btnCenterY - btnH / 2;
  
  // 标题位置：居中偏上
  titleY = height * 0.12;
  
  // 唱片位置：右下角
  vinylX = width - 80;
  vinylY = height - 80;
  
  textAlign(CENTER, CENTER);
  rectMode(CORNER);
}

void draw() {
  // 背景
  drawBackground();
  
  // 标题
  drawTitle();
  
  // 按钮
  drawButton(clawBtnX, clawBtnY, btnW, btnH, "Claw");
  drawButton(clawV2BtnX, clawV2BtnY, btnW, btnH, "Claw_v2");
  
  // 旋转唱片
  drawVinyl();
}

void drawBackground() {
  if (bgImg != null) {
    // 拉伸铺满窗口
    image(bgImg, 0, 0, width, height);
  } else {
    background(30);
  }
  // 半透明暗色遮罩，让前景元素更清晰
  fill(0, 0, 0, 100);
  noStroke();
  rect(0, 0, width, height);
}

void drawTitle() {
  // 标题阴影
  fill(0, 0, 0, 180);
  textFont(titleFont);
  text(title, width / 2 + 2, titleY + 2);
  
  // 标题主体
  fill(255, 255, 255);
  text(title, width / 2, titleY);
  
  // 装饰线
  stroke(255, 255, 255, 150);
  strokeWeight(2);
  float lineW = 300;
  float lineY = titleY + 40;
  line(width / 2 - lineW / 2, lineY, width / 2 + lineW / 2, lineY);
  noStroke();
}

void drawButton(float x, float y, float w, float h, String label) {
  boolean hovered = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  
  // 按钮背景
  if (hovered) {
    fill(btnHover);
    stroke(255, 255, 255, 200);
    strokeWeight(2);
  } else {
    fill(btnColor);
    stroke(255, 255, 255, 80);
    strokeWeight(1.5);
  }
  rect(x, y, w, h, 12);
  
  // 按钮文字
  fill(btnText);
  textFont(btnFont);
  noStroke();
  text(label, x + w / 2, y + h / 2);
}

void drawVinyl() {
  pushMatrix();
  translate(vinylX, vinylY);
  
  // 如果音乐播放中，唱片旋转
  if (musicPlaying) {
    vinylAngle += 0.03;
  }
  rotate(vinylAngle);
  
  // 唱片主体
  fill(40);
  noStroke();
  ellipse(0, 0, vinylR * 2, vinylR * 2);
  
  // 唱片纹理环
  for (int i = 0; i < 8; i++) {
    float ringR = vinylR * (0.85 - i * 0.08);
    stroke(60, 60, 60);
    strokeWeight(0.5);
    noFill();
    ellipse(0, 0, ringR * 2, ringR * 2);
  }
  
  // 唱片中心标签
  float labelR = vinylR * 0.45;
  fill(200, 50, 50);
  noStroke();
  ellipse(0, 0, labelR * 2, labelR * 2);
  
  // 中心小孔
  fill(30);
  ellipse(0, 0, 5, 5);
  
  // 高光
  noFill();
  stroke(255, 255, 255, 40);
  strokeWeight(1);
  arc(0, 0, vinylR * 1.8, vinylR * 1.8, -PI * 0.25, PI * 0.25);
  noStroke();
  
  popMatrix();
  
  // 悬停提示
  float d = dist(mouseX, mouseY, vinylX, vinylY);
  if (d < vinylR) {
    fill(255, 255, 255, 180);
    textFont(tipFont);
    text(musicPlaying ? "暂停音乐" : "播放音乐", vinylX, vinylY - vinylR - 15);
  }
}

void mousePressed() {
  // 检查 Claw 按钮
  if (mouseX > clawBtnX && mouseX < clawBtnX + btnW &&
      mouseY > clawBtnY && mouseY < clawBtnY + btnH) {
    clickSfx.play();
    println("Claw 按钮被点击");
  }
  
  // 检查 Claw_v2 按钮
  if (mouseX > clawV2BtnX && mouseX < clawV2BtnX + btnW &&
      mouseY > clawV2BtnY && mouseY < clawV2BtnY + btnH) {
    clickSfx.play();
    println("Claw_v2 按钮被点击");
  }
  
  // 检查唱片
  float d = dist(mouseX, mouseY, vinylX, vinylY);
  if (d < vinylR) {
    musicPlaying = !musicPlaying;
    if (musicPlaying) {
      // 从暂停位置继续播放，而非从头开始
      bgm.play();
    } else {
      bgm.pause();
    }
  }
}