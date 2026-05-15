import processing.sound.*;

// ==================== 状态机 ====================
final int MAIN       = 0;
final int TRANS_OUT  = 1;
final int VIEW       = 2;
final int TRANS_VIEW = 3;
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
float vinylR = 45;
boolean musicPlaying = true;

// ==================== 主菜单：按钮 ====================
float btnW = 180, btnH = 60;
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

// 视图按钮
float vBtnW = 80, vBtnH = 36, vBtnGap = 20;
float vBtnY;
float vBtnFrontX, vBtnUpX, vBtnLeftX;

// 首页按钮
float homeX = 30, homeY = 30, homeSize = 44;

// 图片显示区域
float imgAreaX, imgAreaY, imgAreaW, imgAreaH;

// View 过渡
int viewTransFrame = 0;
boolean viewTransIn = false;

// ==================== SETUP ====================
void setup() {
  size(1000, 700);

  // 字体
  titleFont  = createFont("Microsoft YaHei", 42, true);
  btnFont    = createFont("Microsoft YaHei", 22, true);
  tipFont    = createFont("Microsoft YaHei", 12, true);
  viewBtnFont = createFont("Microsoft YaHei", 18, true);

  // 资源
  bgImg = loadImage("BG.jpg");
  bgm = new SoundFile(this, "BGM.mp3");
  clickSfx = new SoundFile(this, "Sd1.wav");
  bgm.amp(0.5);
  bgm.loop();

  // 主菜单按钮位置
  float cx = width / 2;
  float gap = 40;
  float btnCY = height * 0.55;
  clawBtnX  = cx - btnW - gap / 2;
  clawBtnY  = btnCY - btnH / 2;
  clawV2BtnX = cx + gap / 2;
  clawV2BtnY = btnCY - btnH / 2;

  titleY = height * 0.12;
  vinylX = width - 80;
  vinylY = height - 80;

  // 视图按钮位置
  vBtnY = 26;
  vBtnFrontX = homeX + homeSize + 30;
  vBtnUpX    = vBtnFrontX + vBtnW + vBtnGap;
  vBtnLeftX  = vBtnUpX    + vBtnW + vBtnGap;

  // 图片区域
  imgAreaX = 80;
  imgAreaY = 110;
  imgAreaW = width - 160;
  imgAreaH = height - 190;

  textAlign(CENTER, CENTER);
  rectMode(CORNER);
}

// ==================== DRAW ====================
void draw() {
  switch (state) {
    case MAIN:      drawMain();      break;
    case TRANS_OUT: drawTransOut();  break;
    case VIEW:      drawView();      break;
    case TRANS_VIEW:drawTransView(); break;
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
  animStartSize = 22;

  animEndX = width / 2;
  animEndY = height / 2;
  animEndSize = 60;
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
  viewTransIn = true;
  viewTransFrame = frameCount;
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
  // 黑色背景
  background(20);

  // 图片淡入效果
  float fade = 1.0;
  if (viewTransIn) {
    int e = frameCount - viewTransFrame;
    if (e < 15) {
      fade = map(e, 0, 15, 0, 1);
    } else {
      viewTransIn = false;
    }
  }

  if (currentViewImg != null) {
    tint(255, fade * 255);
    // 居中按比例显示
    float scale = min(imgAreaW / currentViewImg.width, imgAreaH / currentViewImg.height);
    float iw = currentViewImg.width * scale;
    float ih = currentViewImg.height * scale;
    float ix = width / 2 - iw / 2;
    float iy = imgAreaY + (imgAreaH - ih) / 2;
    image(currentViewImg, ix, iy, iw, ih);
    noTint();
  }

  // 上方按钮
  drawHomeButton();
  drawViewButton(vBtnFrontX, vBtnY, vBtnW, vBtnH, "前", currentView.equals("Front"));
  drawViewButton(vBtnUpX,    vBtnY, vBtnW, vBtnH, "上", currentView.equals("Up"));
  drawViewButton(vBtnLeftX,  vBtnY, vBtnW, vBtnH, "左", currentView.equals("Left"));

  // 部件名称标签
  fill(255, 120);
  textFont(viewBtnFont);
  String label = currentPart + " — " + getViewCN(currentView);
  text(label, width / 2, height - 30);

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

  // 房屋图标
  float cx = homeX + homeSize / 2;
  float cy = homeY + homeSize / 2;
  float s = homeSize * 0.28;
  noStroke();
  fill(redBorder);
  // 屋顶三角形
  triangle(cx - s, cy - s * 0.4f, cx, cy - s * 1.4f, cx + s, cy - s * 0.4f);
  // 屋身矩形
  rect(cx - s * 0.75f, cy - s * 0.4f, s * 1.5f, s * 1.4f);
  // 门
  fill(20);
  rect(cx - s * 0.2f, cy + s * 0.2f, s * 0.4f, s * 0.8f);

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

// ==================== 视图间过渡 ====================
void drawTransView() {
  int elapsed = frameCount - transStartFrame;
  float t = min(float(elapsed) / 12.0, 1.0);  // 0.2秒
  float fade = 0;

  // 前一半：旧图淡出
  if (t < 0.5) {
    drawViewWithFade(map(t, 0, 0.5, 1, 0));
  } else {
    // 后一半：新图淡入
    updateCurrentImage();
    drawViewWithFade(map(t, 0.5, 1, 0, 1));
  }

  if (t >= 1.0) {
    state = VIEW;
    updateCurrentImage();
    viewTransIn = true;
    viewTransFrame = frameCount;
  }
}

void drawViewWithFade(float alpha) {
  background(20);

  if (currentViewImg != null) {
    tint(255, alpha * 255);
    float scale = min(imgAreaW / currentViewImg.width, imgAreaH / currentViewImg.height);
    float iw = currentViewImg.width * scale;
    float ih = currentViewImg.height * scale;
    image(currentViewImg, width / 2 - iw / 2, imgAreaY + (imgAreaH - ih) / 2, iw, ih);
    noTint();
  }

  drawHomeButton();
  drawViewButton(vBtnFrontX, vBtnY, vBtnW, vBtnH, "前", currentView.equals("Front"));
  drawViewButton(vBtnUpX,    vBtnY, vBtnW, vBtnH, "上", currentView.equals("Up"));
  drawViewButton(vBtnLeftX,  vBtnY, vBtnW, vBtnH, "左", currentView.equals("Left"));

  fill(255, 120);
  textFont(viewBtnFont);
  text(currentPart + " — " + getViewCN(currentView), width / 2, height - 30);

  drawVinyl();
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

  float d = dist(mouseX, mouseY, vinylX, vinylY);
  if (d < vinylR) {
    fill(255, 255, 255, 180);
    textFont(tipFont);
    text(musicPlaying ? "暂停音乐" : "播放音乐", vinylX, vinylY - vinylR - 15);
  }
}

// ==================== 鼠标事件 ====================
void mousePressed() {
  // 唱片始终可点击
  float d = dist(mouseX, mouseY, vinylX, vinylY);
  if (d < vinylR) {
    musicPlaying = !musicPlaying;
    if (musicPlaying) bgm.play();
    else bgm.pause();
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
    currentView = newView;
    state = TRANS_VIEW;
    transStartFrame = frameCount;
  }
}