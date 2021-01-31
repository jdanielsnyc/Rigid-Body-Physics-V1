int level = 1;
boolean started = false, died = false;
int playerIndex = 0;
float deathOpacity = 0, deathTimer = 0, aniTimer;

void runGame() {
  if (level == 1) {
    if (!started) {
      died = false;
      playerIndex = 0;
      for (int i = 0; i < 6; i++) {
        if (i < 3) {
          Object newObj = buildObject("crate");
          newObj.setMass(-1);
          newObj.setMu(5);
          newObj.setPos(300 + 100*i, 300);
          world.addObj(newObj);
          started = true;
          playerIndex++;
        }
        else {
          Object newObj = buildObject("crate");
          newObj.setMass(-1);
          newObj.setMu(5);
          newObj.setPos(300 + 100*i, 200);
          world.addObj(newObj);
          started = true;
          playerIndex++;
        }
      }
      
      world.addObj(buildObject("crate"));
      world.objects.get(playerIndex + 4).setMass(-1);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setPos(900, 600);
      started = true;
      playerIndex++;
      
      world.addObj(buildObject("crate"));
      world.objects.get(playerIndex + 4).setMass(-1);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setPos(1000, 600);
      started = true;
      playerIndex++;
      
      world.addObj(buildObject("crate"));
      world.objects.get(playerIndex + 4).setMass(-1);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setPos(1100, 600);
      started = true;
      playerIndex++;
      
      world.addObj(buildObject("crate"));
      world.objects.get(playerIndex + 4).setMass(-1);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setPos(1100, 500);
      started = true;
      playerIndex++;
      
      world.addObj(buildObject("crate"));
      world.objects.get(playerIndex + 4).setMass(-1);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setPos(1100, 400);
      started = true;
      playerIndex++;
      
      world.addObj(buildObject("crate"));
      world.objects.get(playerIndex + 4).setMass(-1);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setPos(1100, 300);
      started = true;
      playerIndex++;
      
      world.addObj(buildObject("crate"));
      world.objects.get(playerIndex + 4).setMass(-1);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setPos(1100, 200);
      started = true;
      playerIndex++;
      
      world.addObj(buildObject("crate"));
      world.objects.get(playerIndex + 4).setMass(-1);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setPos(700, 600);
      started = true;
      playerIndex++;
      
      world.addObj(buildObject("tire"));
      world.objects.get(playerIndex + 4).setMass(100);
      world.objects.get(playerIndex + 4).setMu(5);
      world.objects.get(playerIndex + 4).setE(0);
      world.objects.get(playerIndex + 4).setPos(300, 100);
      started = true;
    }
  }
  
  if(!world.objects.get(playerIndex + 4).colliding) {
    world.objects.get(playerIndex + 4).setAVel(0);
  }
  
  if (world.objects.get(playerIndex + 4).getPos().y > 610) {
    died = true;
    started = false;
    world.clear();
    deathOpacity = 255;
  }
  
  float maxSize = 100;
  float animationLength = 50;
  int pulseCount = 5;
  int maxOpacity = 250;
  noStroke();
  for (int i = 0; i < pulseCount; i++) {
    float currentSize = (maxSize * ((aniTimer + i * animationLength/pulseCount) % animationLength) / animationLength);
    float o = maxOpacity * sqrt((1 - currentSize / maxSize));
    fill(195, 0, 0, o);
    ellipse(700, 500, currentSize, currentSize);
  }
  
  if (!died) {
    if (dist(world.objects.get(playerIndex + 4).getPos().x, world.objects.get(playerIndex + 4).getPos().y, 700, 500) < 100) {
      gamePreset = false;
      rocketPreset = false;
      world.clear();
      winOpacity = 255;
    }
  }
    
  textFont(bigFont);
  fill(150, deathOpacity);
  text("YOU DIED!", 200, 400);
  if (deathOpacity > 0) {
    deathOpacity-=5;
  }
  else deathOpacity = 0;
  aniTimer++;
}


void runRocket() {
  if (!started) {
    playerIndex = 0;
  }
}