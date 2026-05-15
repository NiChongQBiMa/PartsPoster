import processing.sound.*;

// ==================== 状态机 ====================
final int MAIN       = 0;
final int TRANS_OUT  = 1;
final int VIEW       = 2;
int state = MAIN;

int transStartFrame;
int transDuration = 24;  // 0.4秒 @ 60fps
String transPart = "";   // "Claw" 或 "Claw2"

// ==================== 资源 ====================
PImage bgImg;
SoundFile bgm;
SoundFile clickSfx;

PImage clawFront, clawUp, clawLeft;
PImage claw2Front, claw2Up, claw2Left;
PImage currentViewImg;

// ==================== 中文字体 ====================
PFont titleFont;
PFont btnFont;
PFont tipFont;
PFont viewBtnFont;

// ==================== 唱片 ====================
float vinylAngle = 0;
float vinylX, vinylY;
float vinylR = 50;
boolean musicPlaying = true;

// ==================== 主菜单：按钮 ====================
float btnW = 200, btnH = 66;
float clawBtnX, clawBtnY;
float clawV2BtnX, clawV2BtnY;
color btnColor  = color(60, 60, 60, 200);
color btnHover  = color(100, 100, 100, 220);
color btnText   = color(255);

// ==================== 主菜单：标题 ====================
String title = "零部件电子海报";
float titleY;

// ==================== 过渡动画变量 ====================
float animTextX, animTextY, animTextSize;
float animStartX, animStartY, animStartSize;
float animEndX, animEndY, animEndSize;
String animLabel = "";

// ==================== 视图页 ====================
String currentPart  = "";
String currentView  = "Front";

color tiffany = color(78, 205, 196);    // 蒂芙尼蓝
color tiffanyFill = color(78, 205, 196);
color redBorder = color(220, 60, 60);

// 视图按钮（居中）
float vBtnW = 90, vBtnH = 40, vBtnGap = 24;
float vBtnY;
float vBtnFrontX, vBtnUpX, vBtnLeftX;

// 首页按钮
float homeX = 30, homeY = 30, homeSize = 48;

// View 切换动画
PImage prevViewImg;
int viewSwitchFrame = 0;
boolean viewSwitching = false;

// ==================== SETUP ====================
void setup() {
  size(1366, 768);
  pixelDensity(1);       // Win7 兼容，避免 HiDPI 缩放模糊
  smooth();              // 抗锯齿，文字/图形边缘更平滑
  hint(ENABLE_STROKE_PURE); // 描边精确渲染

  // 字体（适配 1366×768 稍放大）
  titleFont   = createFont("Microsoft YaHei", 48, true);
  btnFont     = createFont("Microsoft YaHei", 26, true);
  tipFont     = createFont("Microsoft YaHei", 14, true);
  viewBtnFont = createFont("Microsoft YaHei", 20, true);

  // 资源
  bgImg = loadImage("BG.jpg");
  bgm = new SoundFile(this, "BGM.mp3");
  clickSfx = new SoundFile(this, "Sd1.wav");
  bgm.amp(0.5);
  bgm.loop();

  // 主菜单按钮位置
  float cx = width / 2;
  float gap = 50;
  float btnCY = height * 0.55;
  clawBtnX   = cx - btnW - gap / 2;
  clawBtnY   = btnCY - btnH / 2;
  clawV2BtnX = cx + gap / 2;
  clawV2BtnY = btnCY - btnH / 2;

  titleY = height * 0.12;
  vinylX = width - 90;
  vinylY = height - 90;

  // 视图按钮位置（居中）
  vBtnY = 30;
  float totalBtnW = vBtnW * 3 + vBtnGap * 2;
  float btnStartX = (width - totalBtnW) / 2;
  vBtnFrontX = btnStartX;
  vBtnUpX    = btnStartX + vBtnW + vBtnGap;
  vBtnLeftX  = btnStartX + (vBtnW + vBtnGap) * 2;

  textAlign(CENTER, CENTER);
  rectMode(CORNER);
}

// ==================== DRAW ====================
void draw() {
  switch (state) {
    case MAIN:      drawMain();      break;
    case TRANS_OUT: drawTransOut();  break;
    case VIEW:      drawView();      break;
  }
}

// ==================== 主菜单 ====================
void drawMain() {
  drawBg();
  drawTitle();
  drawButton(clawBtnX, clawBtnY, btnW, btnH, "Claw");
  drawButton(clawV2BtnX, clawV2BtnY, btnW, btnH, "Claw_v2");
  drawVinyl();
}

void drawBg() {
  if (bgImg != null) {
    image(bgImg, 0, 0, width, height);
  } else {
    background(30);
  }
  fill(0, 0, 0, 100);
  noStroke();
  rect(0, 0, width, height);
}

void drawTitle() {
  fill(0, 0, 0, 180);
  textFont(titleFont);
  text(title, width / 2 + 2, titleY + 2);
  fill(255);
  text(title, width / 2, titleY);

  stroke(255, 255, 255, 150);
  strokeWeight(2);
  float lw = 300;
  float ly = titleY + 40;
  line(width / 2 - lw / 2, ly, width / 2 + lw / 2, ly);
  noStroke();
}

void drawButton(float x, float y, float w, float h, String label) {
  boolean hover = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  if (hover) {
    fill(btnHover);
    stroke(255, 255, 255, 200);
    strokeWeight(2);
  } else {
    fill(btnColor);
    stroke(255, 255, 255, 80);
    strokeWeight(1.5);
  }
  rect(x, y, w, h, 12);
  fill(btnText);
  textFont(btnFont);
  noStroke();
  text(label, x + w / 2, y + h / 2);
}

// ==================== 过渡动画（主菜单 → 视图） ====================
void startTransition(String part, float sx, float sy, String label) {
  state = TRANS_OUT;
  transStartFrame = frameCount;
  transPart = part;
  animLabel = label;

  animStartX = sx;
  animStartY = sy;
  animStartSize = 26;

  animEndX = width / 2;
  animEndY = height / 2;
  animEndSize = 72;
}

void drawTransOut() {
  int elapsed = frameCount - transStartFrame;
  float t = min(float(elapsed) / transDuration, 1.0);
  float ease = easeOutCubic(t);

  // 背景变暗
  drawBg();
  float dark = lerp(100, 255, ease);
  fill(0, 0, 0, dark);
  noStroke();
  rect(0, 0, width, height);

  // 文字放大并居中
  animTextX = lerp(animStartX, animEndX, ease);
  animTextY = lerp(animStartY, animEndY, ease);
  animTextSize = lerp(animStartSize, animEndSize, ease);

  fill(255);
  textFont(createFont("Microsoft YaHei", animTextSize, true));
  text(animLabel, animTextX, animTextY);

  // 唱片
  drawVinyl();

  // 动画结束 → 进入视图页
  if (t >= 1.0) {
    enterView(transPart);
  }
}

float easeOutCubic(float t) {
  return 1 - pow(1 - t, 3);
}

void enterView(String part) {
  state = VIEW;
  currentPart = part;
  currentView = "Front";
  loadPartImages(part);
  updateCurrentImage();
  prevViewImg = null;
  viewSwitching = true;
  viewSwitchFrame = frameCount;
}

void loadPartImages(String part) {
  if (part.equals("Claw")) {
    clawFront = loadImage("Claw_Front.png");
    clawUp    = loadImage("Claw_Up.png");
    clawLeft  = loadImage("Claw_Left.PNG");
  } else {
    claw2Front = loadImage("Claw2_Front.png");
    claw2Up    = loadImage("Claw2_Up.png");
    claw2Left  = loadImage("Claw2_Left.png");
  }
}

void updateCurrentImage() {
  if (currentPart.equals("Claw")) {
    if (currentView.equals("Front")) currentViewImg = clawFront;
    else if (currentView.equals("Up")) currentViewImg = clawUp;
    else currentViewImg = clawLeft;
  } else {
    if (currentView.equals("Front")) currentViewImg = claw2Front;
    else if (currentView.equals("Up")) currentViewImg = claw2Up;
    else currentViewImg = claw2Left;
  }
}

// ==================== 视图页 ====================
void drawView() {
  background(20);

  // 图片全屏显示（被按钮遮盖）
  if (currentViewImg != null) {
    float scale = max(float(width) / currentViewImg.width, float(height) / currentViewImg.height);
    float iw = currentViewImg.width * scale;
    float ih = currentViewImg.height * scale;
    float ix = (width - iw) / 2;
    float iy = (height - ih) / 2;

    if (viewSwitching && prevViewImg != null) {
      // 视图切换：旧图淡出 + 新图淡入
      int elapsed = frameCount - viewSwitchFrame;
      float t = min(float(elapsed) / 15.0, 1.0);
      // 旧图
      tint(255, (1 - t) * 255);
      image(prevViewImg, ix, iy, iw, ih);
      // 新图
      tint(255, t * 255);
      image(currentViewImg, ix, iy, iw, ih);
      noTint();
      if (t >= 1.0) {
        viewSwitching = false;
        prevViewImg = null;
      }
    } else if (viewSwitching) {
      // 刚进入视图：新图淡入
      int elapsed = frameCount - viewSwitchFrame;
      float t = min(float(elapsed) / 15.0, 1.0);
      tint(255, t * 255);
      image(currentViewImg, ix, iy, iw, ih);
      noTint();
      if (t >= 1.0) {
        viewSwitching = false;
      }
    } else {
      // 正常显示
      image(currentViewImg, ix, iy, iw, ih);
    }
  }

  // 上方按钮
  drawHomeButton();
  drawViewButton(vBtnFrontX, vBtnY, vBtnW, vBtnH, "前", currentView.equals("Front"));
  drawViewButton(vBtnUpX,    vBtnY, vBtnW, vBtnH, "上", currentView.equals("Up"));
  drawViewButton(vBtnLeftX,  vBtnY, vBtnW, vBtnH, "左", currentView.equals("Left"));

  // 部件名称标签
  fill(0, 0, 0, 160);
  noStroke();
  rect(0, height - 36, width, 36);
  fill(255, 200);
  textFont(viewBtnFont);
  text(currentPart + " — " + getViewCN(currentView), width / 2, height - 18);

  // 唱片
  drawVinyl();
}

String getViewCN(String v) {
  if (v.equals("Front")) return "主视图";
  if (v.equals("Up"))    return "俯视图";
  return "左视图";
}

void drawHomeButton() {
  boolean hover = mouseX > homeX && mouseX < homeX + homeSize &&
                  mouseY > homeY && mouseY < homeY + homeSize;

  // 边框
  stroke(redBorder);
  strokeWeight(2.5);
  if (hover) {
    fill(redBorder, 40);
  } else {
    noFill();
  }
  rect(homeX, homeY, homeSize, homeSize, 10);

  // 房屋图标（扁一点）
  float cx = homeX + homeSize / 2;
  float cy = homeY + homeSize / 2;
  float s = homeSize * 0.30;
  noStroke();
  fill(redBorder);
  // 屋顶（矮三角形）
  triangle(cx - s * 1.1, cy - s * 0.2, cx, cy - s * 1.0, cx + s * 1.1, cy - s * 0.2);
  // 屋身（扁矩形）
  rect(cx - s * 0.85, cy - s * 0.2, s * 1.7, s * 0.9);
  // 门
  fill(20);
  rect(cx - s * 0.2, cy + s * 0.05, s * 0.4, s * 0.65);

  // 悬停文字
  if (hover) {
    fill(255);
    textFont(tipFont);
    text("返回主菜单", cx, homeY + homeSize + 14);
  }
}

void drawViewButton(float x, float y, float w, float h, String label, boolean active) {
  boolean hover = mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;

  stroke(tiffany);
  strokeWeight(2);

  if (active) {
    fill(tiffanyFill);
  } else if (hover) {
    fill(tiffanyFill, 60);
  } else {
    noFill();
  }
  rect(x, y, w, h, 8);

  fill(active ? 255 : tiffany);
  textFont(viewBtnFont);
  noStroke();
  text(label, x + w / 2, y + h / 2);

  // 激活指示点
  if (active) {
    noStroke();
    fill(tiffany);
    ellipse(x + w / 2, y + h + 7, 6, 6);
  }
}

// ==================== 唱片（始终显示） ====================
void drawVinyl() {
  pushMatrix();
  translate(vinylX, vinylY);
  if (musicPlaying) vinylAngle += 0.03;
  rotate(vinylAngle);

  fill(40); noStroke();
  ellipse(0, 0, vinylR * 2, vinylR * 2);
  for (int i = 0; i < 8; i++) {
    float rr = vinylR * (0.85 - i * 0.08);
    stroke(60); strokeWeight(0.5); noFill();
    ellipse(0, 0, rr * 2, rr * 2);
  }
  float lr = vinylR * 0.45;
  fill(200, 50, 50); noStroke();
  ellipse(0, 0, lr * 2, lr * 2);
  fill(30);
  ellipse(0, 0, 5, 5);
  noFill(); stroke(255, 255, 255, 40); strokeWeight(1);
  arc(0, 0, vinylR * 1.8, vinylR * 1.8, -PI * 0.25, PI * 0.25);
  noStroke();
  popMatrix();

  // 静音时绘制红叉
  if (!musicPlaying) {
    stroke(255, 50, 50);
    strokeWeight(3);
    float crossR = vinylR * 1.1;
    line(vinylX - crossR, vinylY - crossR, vinylX + crossR, vinylY + crossR);
    line(vinylX + crossR, vinylY - crossR, vinylX - crossR, vinylY + crossR);
    noStroke();
  }

  float d = dist(mouseX, mouseY, vinylX, vinylY);
  if (d < vinylR) {
    fill(255, 255, 255, 180);
    textFont(tipFont);
    text(musicPlaying ? "静音" : "取消静音", vinylX, vinylY - vinylR - 15);
  }
}

// ==================== 鼠标事件 ====================
void mousePressed() {
  // 唱片始终可点击
  float d = dist(mouseX, mouseY, vinylX, vinylY);
  if (d < vinylR) {
    musicPlaying = !musicPlaying;
    if (musicPlaying) {
      bgm.amp(0.5);  // 恢复音量（音乐始终在后台循环）
    } else {
      bgm.amp(0);    // 静音（不停止循环）
    }
    return;
  }

  switch (state) {
    case MAIN:
      mouseMain();
      break;
    case VIEW:
      mouseView();
      break;
  }
}

void mouseMain() {
  // Claw 按钮
  if (mouseX > clawBtnX && mouseX < clawBtnX + btnW &&
      mouseY > clawBtnY && mouseY < clawBtnY + btnH) {
    clickSfx.play();
    startTransition("Claw", clawBtnX + btnW / 2, clawBtnY + btnH / 2, "Claw");
  }
  // Claw_v2 按钮
  if (mouseX > clawV2BtnX && mouseX < clawV2BtnX + btnW &&
      mouseY > clawV2BtnY && mouseY < clawV2BtnY + btnH) {
    clickSfx.play();
    startTransition("Claw2", clawV2BtnX + btnW / 2, clawV2BtnY + btnH / 2, "Claw_v2");
  }
}

void mouseView() {
  // 首页按钮
  if (mouseX > homeX && mouseX < homeX + homeSize &&
      mouseY > homeY && mouseY < homeY + homeSize) {
    clickSfx.play();
    state = MAIN;
    return;
  }

  // 视图按钮
  String newView = null;
  if (mouseX > vBtnFrontX && mouseX < vBtnFrontX + vBtnW &&
      mouseY > vBtnY && mouseY < vBtnY + vBtnH) {
    newView = "Front";
  }
  if (mouseX > vBtnUpX && mouseX < vBtnUpX + vBtnW &&
      mouseY > vBtnY && mouseY < vBtnY + vBtnH) {
    newView = "Up";
  }
  if (mouseX > vBtnLeftX && mouseX < vBtnLeftX + vBtnW &&
      mouseY > vBtnY && mouseY < vBtnY + vBtnH) {
    newView = "Left";
  }

  if (newView != null && !newView.equals(currentView)) {
    clickSfx.play();
    prevViewImg = currentViewImg;
    currentView = newView;
    updateCurrentImage();
    viewSwitching = true;
    viewSwitchFrame = frameCount;
  }
}