float SIconv = 30;

void runMenus() {
  noStroke();
  overMenu = false;
  defaultMenu();
  if (statMenu) {
    if (itemMenu) {
      statMenu(220, 15); // FINISH HITBOX DISPLAY AND VALUE EDITING
    }
    else statMenu(865, 15);
  }
  if (itemMenu) {
    itemMenu();
  }
}


boolean choosingObj = false;
void defaultMenu() {
  float x = 15, y = 15;
  boolean overClear, overObj, overData, overPresets;
  
  if (mouseX > x && mouseX < x + 190 && mouseY > y && mouseY < y + 150) overMenu = true;
  
  overClear = mouseX > x && mouseX < x + 50 && mouseY > y && mouseY < y + 150;
  overObj = mouseX > x + 60 && mouseX < x + 180 && mouseY > y + 10 && mouseY < y + 100;
  overData = mouseX > x + 60 && mouseX < x + 115 && mouseY > y + 110 && mouseY < y + 140;
  overPresets = mouseX > x + 125 && mouseX < x + 180 && mouseY > y + 110 && mouseY < y + 140;
  
  fill(110);
  rect(x, y, 190, 150, 20); // background
  fill(255, 55, 55);
  if (overClear) {
    fill(255, 95, 95);
    if (mouseReleased) {
      world.clear();
      statMenu = false;
      itemMenu = false;
    }
  }
  rect(x, y, 100, 150, 20); // clear
  fill(110);
  rect(x + 50, y, 100, 150);
  fill(90);
  rect(x + 60, y + 10, 120, 90, 8); // selected object/field
  
  float px = x + 60, py = y + 10;
  
  if (placeCode== 0) {
    image(tireIcon, px + 20, py + 5);
  }
  else if (placeCode== 1) {
    image(fruitIcon, px + 27.5, py + 12.5);
  }
  else if (placeCode== 2) {
    image(diceIcon, px + 6, py + 10);
  }
  else if (placeCode== 3) {
    image(crateIcon, px + 25, py + 10);
  }
  else if (placeCode== 4) {
    image(pinIcon, px + 24, py + 5);
  }
  else if (placeCode== 5) {
    image(rocketIcon, px + 5, py + 15.5);
  }
  else if (placeCode== 6) {
    image(boatIcon, px + 25, py + 7.5);
  }
  else if (placeCode== 7) {
    image(gravIcon, px + 18, py + 5);
  }
  else if (placeCode== 8) {
    image(elecIcon, px + 25, py + 10);
  }
  else if (placeCode== 9) {
    image(magIcon, px + 32, py + 5.5);
  }
    
  if (itemMenu) {
    fill(0, 164, 255);
  }
  else fill(0, 195, 255);
  rect(x + 60, y + 110, 55, 30, 8); // active object/field data list
  if (overData) {
    fill(255, 60);
    rect(x + 60, y + 110, 55, 30, 8);
    if (mouseReleased) {
      itemMenu = !itemMenu;
    }
  }
  fill(255, 174, 0);
  if (overPresets) {
    fill(249, 195, 79);
  }
  rect(x + 125, y + 110, 55, 30, 8); // presets maybe?
  
  if (overObj) {
    choosingObj = true;
  }
  boolean overChooseMenu = choosingObj 
  && (mouseX > x + 60 && mouseX < x + 500 && mouseY > y && mouseY < y + 100
  || mouseX > x + 230 && mouseX < x + 500 && mouseY > y && mouseY < y + 510); 
  if (screenshotMode) {
    overChooseMenu = true;
  }
  if (!overChooseMenu) {
    choosingObj = false;
  }
  else overMenu = true;
  
  if (overChooseMenu) {
    float sx = x + 200, sy = y;
    fill(110);
    triangle(sx, sy + 40, sx + 40, sy + 40, sx + 40, sy + 80);
    rect(sx + 30, sy, 270, 510, 20);
    for (int i = 0; i < 10; ++i) {
      float bx, by;
      if (i%2 == 0) {
        bx = sx + 40; 
        by = sy + 10 + 100 * i/2;
      }
      else {
        bx = sx + 170;
        by = sy + 10 + 100 * (i - 1)/2;
      }
      boolean mouseOverSelection = mouseX > bx && mouseX < bx + 120 && mouseY > by && mouseY < by + 90;
      fill(90);
      if (mouseOverSelection) {
        fill(120);
      }
      rect(bx, by, 120, 90, 8);
      
      if (mouseReleased && mouseOverSelection) {
        placeCode = i;
        fieldType = 0;
        choosingObj = false;
        overChooseMenu = false;
      }
      
      if (i == 0) {
        image(tireIcon, bx + 20, by + 5);
      }
      else if (i == 1) {
        image(fruitIcon, bx + 27.5, by + 12.5);
      }
      else if (i == 2) {
        image(diceIcon, bx + 6, by + 10);
      }
      else if (i == 3) {
        image(crateIcon, bx + 25, by + 10);
      }
      else if (i == 4) {
        image(pinIcon, bx + 24, by + 5);
      }
      else if (i == 5) {
        image(rocketIcon, bx + 5, by + 15.5);
      }
      else if (i == 6) {
        image(boatIcon, bx + 25, by + 7.5);
      }
      else if (i == 7) {
        image(gravIcon, bx + 18, by + 5);
      }
      else if (i == 8) {
        image(elecIcon, bx + 25, by + 10);
      }
      else if (i == 9) {
        image(magIcon, bx + 32, by + 5.5);
      }
    }
  }

}
  
  
int editDirectory = 0; // 0 for mass, 1 for elasticity, 2 for charge, 3 for coefficient of friction
void statMenu(float x, float y) {
  
  Object obj = world.getObj(inspectedObject + 4);
  
  if (mouseX > x && mouseX < x + 400 && mouseY > y && mouseY < y + 300) overMenu = true;
  inMenu = typeMode;
  boolean onClose = mouseX > x && mouseX < x + 60 && mouseY > y && mouseY < y + 60;
  boolean onMass = mouseX > x + 10 && mouseX < x + 115 && mouseY > y + 79 && mouseY < y + 109;
  boolean onBounce = mouseX > x + 120 && mouseX < x + 195 && mouseY > y + 79 && mouseY < y + 109;
  boolean onCharge = mouseX > x + 10 && mouseX < x + 115 && mouseY > y + 129 && mouseY < y + 159;
  boolean onFriction = mouseX > x + 120 && mouseX < x + 195 && mouseY > y + 129 && mouseY < y + 159;
  boolean exitEdit = typeMode && (enterPressed || mousePressed && !onMass && !onBounce && !onCharge && !onFriction);
 
  int mass = int(obj.mass());
  float e = obj.getE(), charge = obj.getCharge(), mu = obj.getMuS(); //  PUT THESE BACK LATER AT [-A-] ONCE YOU ADD THE INHERITANCE FROM OBJECTS
  if (typeMode) {
    
    if (exitEdit) {
      typeMode = false;
      if (float(numberInput) == int(numberInput)) {
        numberInput = str(int(numberInput));
      }
      if (!hasTyped) {
        numberInput = oldInput;
      }
      oldInput = "1";
    }
    
    if (editDirectory == 0) {
      mass = int(numberInput);
      if (exitEdit) {
        if (mass <= 0) {
          mass = 1;
        }
        obj.setMass(mass);
      }
    }
    else if (editDirectory == 1) {
      e = float(numberInput);
      if (exitEdit) {
        obj.setE(e);
      }
    }
    else if (editDirectory == 2) {
      charge = float(numberInput);
      if (exitEdit) {
        obj.setCharge(charge);
      }
    }
    else if (editDirectory == 3) {
      mu = float(numberInput);
      if (exitEdit) {
        obj.setMu(mu);
      }
    }
  }
  
  rect(x + 10, y + 79, 105, 30, 7); // mass box
  rect(x + 10, y + 129, 105, 30, 7); // elasticity box
  rect(x + 120, y + 79, 75, 30, 7); // charge box
  rect(x + 120, y + 129, 75, 30, 7); // friction box
  
  // top heading
  fill(110);
  rect(x, y, 400, 300, 20);
  if (onClose) {
    fill(150);
    if (mouseReleased) {
      statMenu = false;
    }
  }
  else {
    fill(120);
  }
  rect(x, y, 100, 200, 20);
  fill(110);
  rect(x + 60, y, 80, 200);
  fill(190);
  textFont(mainTitle);
  text(obj.name, x + 70, y + 44);
  
  // background
  fill(100);
  rect(x, y + 60, 400, 200);
  rect(x, y + 100, 400, 200, 20);
  
  fill(255, 55, 55);
  ellipse(x + 30, y + 30, 40, 40); // close
  
  // right box
  fill(85);
  rect(x + 205, y + 70, 185, 220, 15); 
  
  // value titles
  fill(180);
  textFont(subTitle);
  text("Pos.", x + 215, y + 100);
  text("Vel.", x + 215, y + 130);
  text("Acc.", x + 215, y + 190);
  text("F", x + 215, y + 250);
  textSize(10);
  text("n", x + 225, y + 253);
  
  PVector pos = obj.getPos();
  PVector vel = obj.getVel();
  PVector acc = obj.getAcc();
  // values
  textFont(text1);
  text("(" + String.format("%.2f", pos.x / SIconv) + ", " + String.format("%.2f", pos.y / SIconv) + ")", x + 265, y + 100);
  text(String.format("%.2f", vel.mag() / SIconv) + " m/s", x + 265, y + 130);
  text("[" + String.format("%.2f", vel.x / SIconv) + ", " + String.format("%.2f", vel.y / SIconv) + "]", x + 215, y + 150);
  text(String.format("%.2f", acc.mag() / SIconv) + " m/s^2", x + 265, y + 190);
  text("[" + String.format("%.2f", acc.x / SIconv) + ", " + String.format("%.2f", acc.y / SIconv) + "]", x + 215, y + 210);
  text(String.format("%.2f", (acc.mag() * mass / SIconv)) + "N", x + 240, y + 250);
  text("[" + String.format("%.2f", (acc.x * mass / SIconv)) + ", " + String.format("%.2f", (acc.y * mass / SIconv)) + "]", x + 215, y + 270);

  fill(85);
  rect(x + 10, y + 180, 185, 110, 15); // hitbox display box
  image(rocketIcon, x + 40, y + 205);  // DELETE AFTER SCREENSHOTS ARE TAKEN

  // have a timer that cycles through each hitbox, highlighting each individual box's set of points as white as opposed to gray for the rest
  
  if (onMass) {
    fill(85);
    rect(x + 10, y + 79, 105, 30, 7); // mass box
    if (mouseReleased) {
      typeMode = true;
      hasTyped = false;
      editDirectory = 0;
      oldInput = str(mass);
      numberInput = "0";
    }
  }
  else if (onBounce) {
    fill(85);
    rect(x + 120, y + 79, 75, 30, 7); // elasticity box
    if (mouseReleased) {
      typeMode = true;
      hasTyped = false;
      editDirectory = 1;
      oldInput = str(e);
      numberInput = "0";
    }
  }
  else if (onCharge) {
    fill(85);
    rect(x + 10, y + 129, 105, 30, 7); // charge box
    if (mouseReleased) {
      typeMode = true;
      hasTyped = false;
      editDirectory = 2;
      oldInput = str(charge);
      numberInput = "0";
    }
  }
  else if (onFriction) {
    fill(85);
    rect(x + 120, y + 129, 75, 30, 7); // friction box
    if (mouseReleased) {
      typeMode = true;
      hasTyped = false;
      editDirectory = 3;
      oldInput = str(mu);
      numberInput = "0";
    }
  }

  if (typeMode) {
    fill(120);
    if (editDirectory == 0) {
      rect(x + 10, y + 79, 105, 30, 7); // mass box
    }
    else if (editDirectory == 1) {
      rect(x + 120, y + 79, 75, 30, 7); // elasticity
    }
    else if (editDirectory == 2) {
      rect(x + 10, y + 129, 105, 30, 7); // charge box
    }
    else if (editDirectory == 3) {
      rect(x + 120, y + 129, 75, 30, 7); // friction box
    }
  }
  
  // charge display
  float bx = x + 23, by = y + 144;
  fill(4, 223, 255);
  triangle(
    bx + 8, by - 2, 
    bx - 1.5, by + 10,
    bx, by - 2
  );
  triangle(
    bx - 8, by + 2, 
    bx + 1.5, by - 10,
    bx, by + 2
  );
  fill(180);
  textFont(text1);
  if (int(charge) == charge && (numberInput.indexOf(".") == -1 || editDirectory != 2)) {
    text(int(charge) + " C", x + 40, y + 150);
  }
  else text(String.format("%.2f", charge) + " C", x + 40, y + 150);
  
  // mass display
  image(massSymbol, x + 13, y + 81);
  if (mass > 99999) {
    int E = 5;
    float decimal = float(mass)/pow(10, E);
    while(float(mass)/pow(10, E + 1) >= 1) {
      E++;
      decimal = float(mass)/pow(10, E);
    }
    text(String.format("%.2f", decimal) + "E" + E + " kg", x + 40, y + 100);
  }
  else text(mass + " kg", x + 40, y + 100);
  
  // elasticity display
  image(bounceSymbol, x + 115, y + 71);
  if (int(e) == e && (numberInput.indexOf(".") == -1 || editDirectory != 1)) {
    text(int(e), x + 156, y + 100);
  }
  else text(String.format("%.2f", e), x + 156, y + 100);
  
  // friction display
  image(frictionSymbol, x + 123, y + 131);
  if (int(mu) == mu && (numberInput.indexOf(".") == -1 || editDirectory != 3)) {
    text(int(mu), x + 156, y + 150);
  }
  else text(String.format("%.2f", mu), x + 156, y + 150);
  
}


boolean objectMenuSelected = true, fieldMenuSelected = false;
int page = 1;

void itemMenu() {
  float x = 1280, y = 0;
  int objectCount = world.objects.size() - 4;
  int fieldCount = world.fields.size();
  
  if (mouseReleased) {
    if (mouseX > x - 130 && mouseX < x - 70 && mouseY > y && mouseY < y + 45) {
      objectMenuSelected = true;
      fieldMenuSelected = false;
      page = 1;
    }
    else if (mouseX > x - 70 && mouseX < x - 10 && mouseY > y && mouseY < y + 45) {
      objectMenuSelected = false;
      fieldMenuSelected = true;
      page = 1;
    }
  }
  
  int maxPages = 0;
  if (objectMenuSelected) {
    maxPages = int((objectCount - objectCount%6)/6);
    if (objectCount%6 != 0 || objectCount == 0) maxPages++;
  }
  else if (fieldMenuSelected) {
    maxPages = int((fieldCount - fieldCount%6)/6);
    if (fieldCount%6 != 0 || fieldCount == 0) maxPages++;
  }
  if (page > maxPages) page = maxPages;
  
  fill(110);
  rect(x - 140, y, 200, 700);
  
  fill(140);
  if (objectMenuSelected) {
    fill(0, 195, 255);
  }
  rect(x - 130, y, 60, 45, 0, 0, 0, 8);
  fill(140);
  if (fieldMenuSelected) {
    fill(255, 55, 55);
  }
  rect(x - 70, y, 60, 45, 0, 0, 8, 0);

  boolean displayUpDown = true;
  for (int i = 0; i < 6; i++) {
    int itemNo = (page - 1)*6 + i;
   
    boolean inactiveBox = false;
    if ((itemNo >= objectCount && objectMenuSelected) || (itemNo >= fieldCount && fieldMenuSelected)) {
      inactiveBox = true;
    }
    
    float sx = x - 130, sy = y + 60 + 105*i;
    boolean mouseInBox = mouseX > x - 130 && mouseX < x - 10 && mouseY > y + 60 + 105*i  && mouseY < y + 150 + 105*i;

    if (mouseInBox && !inactiveBox) {
      // detail box background
      fill(110);
      triangle(sx - 20, sy + 20, sx - 45, sy + 20, sx - 45, sy + 45);
      rect(sx - 225, sy, 180, 120, 8);
      fill(90);
      rect(sx - 215, sy + 10, 160, 30, 5);
      fill(90);
      rect(sx - 215, sy + 50, 160, 60, 5);
      fill(95);
      rect(sx - 215, sy + 50, 160, 30, 5, 5, 0, 0);
      
      if (objectMenuSelected) {
        Object obj = world.getObj(itemNo + 4);
        // detail box text
        fill(180);
        textFont(subTitle);
        text(obj.name, sx - 209, sy + 32); // OBJECT TITLE
        textFont(text2);
        text("x: " + String.format("%.2f", obj.getPos().x / SIconv) + " m", sx - 205, sy + 70);
        text("y: " + String.format("%.2f", obj.getPos().y / SIconv) + " m", sx - 205, sy + 99);
      }
      else if (fieldMenuSelected) {
        Field field = world.getField(itemNo);
        // detail box text
        fill(180);
        textFont(subTitle);
        text(field.name, sx - 209, sy + 32); // Field TITLE
        textFont(text2);
        text("x: " + String.format("%.2f", field.pos.x / SIconv) + " m", sx - 205, sy + 70);
        text("y: " + String.format("%.2f", field.pos.y / SIconv) + " m", sx - 205, sy + 99);
      }
      if (i == 5) {
        displayUpDown = false;
      }
      
      if (mouseReleased && objectMenuSelected) {
        inspectedObject = itemNo;
        statMenu = true;
        itemMenu = false;
      }
      
      fill(80);
    }
    else if (inactiveBox) {
      fill (100);
    }
    else fill(90);
    rect(sx, sy, 120, 90, 8); // obj/field display boxes
    
    if (!inactiveBox) {
      if (objectMenuSelected) {
        Object obj = world.getObj(itemNo + 4);
        if (obj.type == "tire") {
          image(tireIcon, sx + 20, sy + 5);
        }
        else if (obj.name == "Melon") {
          image(melonIcon, sx + 27.5, sy + 12.5);
        }
        else if (obj.name == "Orange") {
          image(orangeIcon, sx + 27.5, sy + 7.5);
        }
        else if (obj.name == "Grapefruit") {
          image(grapefruitIcon, sx + 27.5, sy + 12.5);
        }
        else if (obj.name == "Coconut") {
          image(coconutIcon, sx + 27.5, sy + 12.5);
        }
        else if (obj.type == "die") {
          image(diceIcon, sx + 6, sy + 10);
        }
        else if (obj.type == "crate") {
          image(crateIcon, sx + 25, sy + 10);
        }
        else if (obj.type == "pin") {
          image(pinIcon, sx + 24, sy + 5);
        }
        else if (obj.type == "rocket") {
          image(rocketIcon, sx + 5, sy + 15.5);
        }
        else if (obj.type == "boat") {
          image(boatIcon, sx + 25, sy + 7.5);
        }
      }
      else {
        Field field = world.getField(itemNo);
        if (field.type == "G") {
          image(gravIcon, sx + 18, sy + 5);
        }
        else if (field.type == "E") {
          image(elecIcon, sx + 25, sy + 10);
        }
        else if (field.type == "M") {
          image(magIcon, sx + 32, sy + 5.5);
        }
      }
    }
    
    if (i == 4 && !inactiveBox && mouseX > x - 130 && mouseX < x - 10 && mouseY > y + 60 + 105*i  && mouseY < y + 166 + 105*i) {
      displayUpDown = false;
    }
    
  }
  fill(140);
  rect(x - 140, y + 690, 200, 10);
  
  // up/down buttons
  boolean inPrevPage = mouseX > x - 180 && mouseX < x - 150 && mouseY > y + 575  && mouseY < y + 625;
  boolean inNextPage = mouseX > x - 180 && mouseX < x - 150 && mouseY > y + 635  && mouseY < y + 685;
  if (displayUpDown) {
    fill(110);
    rect(x - 180, y + 575, 30, 50, 8);
    rect(x - 180, y + 635, 30, 50, 8);
    fill(140);
    if (inPrevPage) {
      fill(190);
      if (mouseReleased && page - 1 > 0) {
        page--;
      }
    }
    triangle(x - 173, y + 615, x - 165, y + 585, x - 157, y + 615); // up triangle
    fill(140);
    if (inNextPage) {
      fill(190);
      if (mouseReleased && page + 1 <= maxPages) {
        page++;
      }
    }
    triangle(x - 173, y + 645, x - 165, y + 675, x - 157, y + 645); // down triangle
  }
  
  if (inPrevPage || inNextPage || mouseX > x - 140) overMenu = true;
  
  fill(110);
  rect(x - 230, y - 10, 80, 55, 8);
  fill(90);
  rect(x - 230, y + 10, 80, 35, 0, 0, 8, 8);
  fill(180);
  textFont(subTitle);
  text("pg. " + page, x - 222, y + 33);
}



void setupMenu() {
  
}


void keyPressed() {
  if ((keyCode == 't' || keyCode == 'T')) {
    world.pause = !world.pause;
  }
  if ((keyCode == 'y' || keyCode == 'Y')) {
    skeletonMode = !skeletonMode;
  }
  if ((keyCode == 'u' || keyCode == 'U')) {
    screenshotMode = !screenshotMode;
  }
  
  if (keyCode == ENTER) {
    enterPressed = true;
  }
  if (keyCode == SHIFT) {
    if (placeCode == 9) {
      fieldType = (fieldType + 1)%2;
    }
    else {
      fieldType = (fieldType + 1)%5;
    }
  }
  if (keyCode == BACKSPACE) {
    gamePreset = false;
    rocketPreset = false;
    world.clear();
  }
  if (gamePreset) {
    world.objects.get(playerIndex + 4).setAcc(new PVector(0, 0));
    if (keyCode == UP) {
      if(world.objects.get(playerIndex + 4).colliding) {
        world.objects.get(playerIndex + 4).adjustVel(new PVector(0, -300));
      }
    }
    if (keyCode == LEFT) {
      world.objects.get(playerIndex + 4).setAVel(-5);
    }  
    if (keyCode == RIGHT) {
      world.objects.get(playerIndex + 4).setAVel(5);
    }
  }
  if ((keyCode == 'z' || keyCode == 'Z') && placeCode != 9) {
    fieldShape = (fieldShape + 1)%2;
  }
  if (typeMode) {
    if (keyCode == BACKSPACE) {
      numberInput = "0";
      hasTyped = true;
    }
    if (keyCode == '0') {
      numberInput += "0";
      hasTyped = true;
    }
    if (keyCode == '1') {
      numberInput += "1";
      hasTyped = true;
    }
    if (keyCode == '2') {
      numberInput += "2";
      hasTyped = true;
    }
    if (keyCode == '3') {
      numberInput += "3";
      hasTyped = true;
    }
    if (keyCode == '4') {
      numberInput += "4";
      hasTyped = true;
    }
    if (keyCode == '5') {
      numberInput += "5";
      hasTyped = true;
    }
    if (keyCode == '6') {
      numberInput += "6";
      hasTyped = true;
    }
    if (keyCode == '7') {
      numberInput += "7";
      hasTyped = true;
    }
    if (keyCode == '8') {
      numberInput += "8";
      hasTyped = true;
    }
    if (keyCode == '9') {
      numberInput += "9";
      hasTyped = true;
    }
    if (keyCode == '.' && numberInput.indexOf(".") == -1 && editDirectory != 0) {
      // if there isn't already a decimal point
      numberInput += ".";
      hasTyped = true;
    }
    if (keyCode == '-' && editDirectory == 2) {
      // removes negative sign if there's already one, and adds one of there isn't
      if (numberInput.indexOf("-") == -1) {
        numberInput = "-" + numberInput;
      }
      else {
        numberInput = numberInput.replace("-", "");
      }
      hasTyped = true;
    }
  }
  else {
    if (keyCode == '1') {
      world.clear();
      gamePreset = true;
      rocketPreset = false;
      started = false;
      level = 1;
    }
    if (keyCode == '2') {
      world.clear();
      rocketPreset = true;
      gamePreset = false;
      started = false;
    }
  }
}


void hPill (float x, float y, float w, float h) {
  rect(x + h/2, y, w - h, h); // rect
  ellipse(x + h/2, y + h/2, h, h); // left cap
  ellipse(x + w - h/2, y + h/2, h, h); // right cap
}


void vPill (float x, float y, float w, float h) {
  rect(x, y + w/2, w, h - w); // rect
  ellipse(x + w/2, y + w/2, w, w); // left cap
  ellipse(x + w/2, y + h - w/2, w, w); // right cap
}
