//1D Shallow Water
//Ruichen He <he000239@umn.edu>

//Simulation setup
float x_total_length = 1000; //1000m


static int n = 40;
float dx = x_total_length/n;
float dy = 40;
float maxLength = 20;
float drawHeight = 100;
float heightThreshold = 0.1;
float g = 10; //10m/s^2
float h[] = new float[n];
float hu[] = new float[n];
float dhdt[] = new float[n];
float dhudt[] = new float[n];
float dhdt_mid[] = new float[n];
float dhudt_mid[] = new float[n];
float h_mid[] = new float[n];
float hu_mid[] = new float[n];
float temp1;
float temp2;
String windowTitle = "1D Shallow Water Simulation";
boolean paused = true;
String style = "2";
void init(){
  //Setup init condition
  //
  switch (style){
    case "1":
    {
      for (int i = 0; i < n; i++){ //TODO: Try different initial conditions
        if (i < n/2){
          h[i] = 0.4 * maxLength;
        } else {
          h[i] = (0.4 +  0.6 * (i - n/2)/(float)(n/2)) * maxLength;
        }
        hu[i] = 0;
        hu_mid[i] = 0;
      }
      for (int i = 0; i < n-1; i++){ //TODO: Try different initial conditions
        h_mid[i] = (h[i] + h[i+1])/2;
      }
    }
    break;
    case "2":
    {
      for (int i = 0; i < n; i++){ //TODO: Try different initial conditions
        if (i < n/2){
          h[i] = 0.6 * maxLength;
        } else {
          h[i] = 1 * maxLength;
        }
        hu[i] = 0;
        hu_mid[i] = 0;
      }
      for (int i = 0; i < n-1; i++){ //TODO: Try different initial conditions
        h_mid[i] = (h[i] + h[i+1])/2;
      }
    }
    break;
    default:
    for (int i = 0; i < n; i++){ //TODO: Try different initial conditions
      h[i] = maxLength;
      hu[i] = 0;
      hu_mid[i] = 0;
    }
    for (int i = 0; i < n-1; i++){ //TODO: Try different initial conditions
      h_mid[i] = (h[i] + h[i+1])/2;
    }
  }
}
void redBlue(float u){
  if (u < 0)
    fill(0,0,-255*u);
  else
    fill(255*u,0,0);
}
void colorByTemp(float t) {
//        follow a blackbody color ramp. This is:
//        -From 0 - 0.333, interpolate from black to red
//        -From 0.333 - 0.666, interpolate from red to yellow
//        -From 0.666 - 1.0, interpolate from yellow to white
//        -You can choose any color you like for outside to 0 to 1 range (or simply
//         clamp the input to be from 0 to 1).
  // Clamp the input value to be between 0 and 1
  t = constrain(t, 0, 1);

  float r, g, b;

  // From 0 - 0.333, interpolate from black to red
  if (t < 0.333) {
    r = map(t, 0, 0.333, 0, 255);
    g = 0;
    b = 0;
  } 
  // From 0.333 - 0.666, interpolate from red to yellow
  else if (t < 0.666) {
    r = 255;
    g = map(t, 0.333, 0.666, 0, 255);
    b = 0;
  } 
  // From 0.666 - 1.0, interpolate from yellow to white
  else {
    r = 255;
    g = 255;
    b = map(t, 0.666, 1.0, 0, 255);
  }

  fill(color(r, g, b));
}

void setup(){
  size(1200, 600);
  //Initial tepmapture distribution (linear heat ramp from left to right)
  init();
}

void update(float dt){
  for (int i = 0; i < n-1; i++){
    //This steps is the key, need to recalculate the mid point h and hu every iteration
    h_mid[i] = (h[i] + h[i+1])/2;
    hu_mid[i] = (hu[i] + hu[i+1])/2;
  }
  for (int i = 0; i < n-1; i++){
    //Compute dh/dt (mid) and dhu/dt (mid)
    dhdt_mid[i] = -(hu[i+1] - hu[i])/dx;
    if (h[i+1] > heightThreshold){
      temp1 = pow(hu[i+1], 2) / h[i+1];
    } else {
      temp1 = 0;
    }
    if (h[i] > heightThreshold){
      temp2 = pow(hu[i], 2) / h[i];
    } else {
      temp2 = 0;
    }
    dhudt_mid[i] = -(temp1 - temp2)/dx - 0.5 * g * (pow(h[i+1], 2) - pow(h[i], 2))/dx;
  }
  for (int i = 0; i < n-1; i++){
    h_mid[i] = h_mid[i] + dhdt_mid[i] * dt/2;
    hu_mid[i] = hu_mid[i] + dhudt_mid[i] * dt/2;
  }
  
  for (int i = 0; i < n-2; i++){
    //Compute dh/dt and dhu/dt
    dhdt[i+1] = -(hu_mid[i+1] - hu_mid[i])/dx;
    if (h_mid[i+1] > heightThreshold){
      temp1 = pow(hu_mid[i+1], 2) / h_mid[i+1];
    } else {
      temp1 = 0;
    }
    if (h_mid[i] > heightThreshold){
      temp2 = pow(hu_mid[i], 2) / h_mid[i];
    } else {
      temp2 = 0;
    }
    dhudt[i+1] = -(temp1 - temp2)/dx - 0.5 * g * (pow(h_mid[i+1], 2) - pow(h_mid[i], 2))/dx;
  }
  for (int i = 1; i < n-1; i++){
    h[i] += dhdt[i] * dt;
    hu[i] += dhudt[i] * dt;
  }
  
  h[0] = h[1];
  h[n-1] = h[n-2];
  
  hu[0] = -hu[1];
  hu[n-1] = -hu[n-2];
}

void draw() {
  background(200,200,200);
  
  float dt = 0.01;
  for (int i = 0; i < 20; i++){
    if (!paused) update(dt);
  }
    
  //Draw Heat
  fill(0);
  text("Height:", 22, 305);
  noStroke();
  //println(h);
  for (int i = 0; i < n; i++){
    colorByTemp(h[i]/maxLength);
    pushMatrix();
    translate(100+dx*i,300+0);
    beginShape();
    vertex(-dx/2, -dy/2 - h[i]/maxLength * drawHeight);
    vertex(dx/2, -dy/2 - h[i]/maxLength * drawHeight);
    vertex(dx/2, dy/2);
    vertex(-dx/2, dy/2);
    endShape();
    popMatrix();
  }
  noFill();
  stroke(1);
  //rect(100-dx/2,300-dy/2,n*dx,dy);
  //println("x", 100-dx/2);
  //println("y", 100-dy/2);
  
  
  fill(0);
  text("dh/dt:", 22, 405);
  noStroke();
  for (int i = 0; i < n; i++){
    redBlue(4*dhdt[i]);
    pushMatrix();
    translate(100+dx*i,400+0);
    beginShape();
    vertex(-dx/2, -dy/2);
    vertex(dx/2, -dy/2);
    vertex(dx/2, dy/2);
    vertex(-dx/2, dy/2);
    endShape();
    popMatrix();
  }
  noFill();
  stroke(1);
  rect(100-dx/2,400-dy/2,n*dx,dy);
  
  fill(0);
  text("dhu/dt:", 22, 505);
  noStroke();
  for (int i = 0; i < n; i++){
    redBlue(4*dhudt[i]);
    pushMatrix();
    translate(100+dx*i,500+0);
    beginShape();
    vertex(-dx/2, -dy/2);
    vertex(dx/2, -dy/2);
    vertex(dx/2, dy/2);
    vertex(-dx/2, dy/2);
    endShape();
    popMatrix();
  }
  noFill();
  stroke(1);
  rect(100-dx/2,500-dy/2,n*dx,dy);
  
  if (paused)
    surface.setTitle(windowTitle + " [PAUSED]");
  else
    surface.setTitle(windowTitle + " "+ nf(frameRate,0,2) + "FPS");
}

void keyPressed(){
  if (key == 'r'){
    println("Resetting Simulation");
    init();
  }
  else {
    paused = !paused;
  }
}
