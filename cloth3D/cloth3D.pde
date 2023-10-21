import java.util.HashMap;
import java.util.Map;
import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;
// ----------- Example using Camera class -------------------- //
Camera camera;
import java.util.ArrayList;
Map<Integer, Node> nodeMap = new HashMap<>();
Map<Integer, Link> linkMap = new HashMap<>();
Map<Integer, Surface> surfaceMap = new HashMap<>();
Map<Integer, Obstacle> obstacleMap = new HashMap<>();
PImage cloth_img;
PImage pumpkin_img;
PShape pumpkin;



String nodeFile = "nodes_cloth.txt";
String linkFile = "links_cloth.txt";
String surfaceFile = "tri_surface_cloth.txt";
String outputFile = "temp.txt";

// Physics Settig
Vec3 gravity = new Vec3(0, 10, 0);
Vec3 v_air = new Vec3(0, 0, 0);
float density_air = 1000;
float Cd = 2;
// Scaling factor for the scene
float scene_scale = width / 10.0f;

// Simulation Parameters
int relaxation_steps = 1;
int sub_steps = 10;
float cor = 0.995; // Control the oscillation
float cor_stretch = 0.1;
boolean DEBUG = false;
boolean WITHAIRDRAG = true;

String output_path; 
//World setting
int mass = 1; // This can be moved to surfaces.txt in the future, when we want to do more complicated physics simulation
Vec3 floor_pos = new Vec3(0, 10, 0);
boolean mouseIsPressed = false;
int chosenNodeId = -1;
Vec2 mousePressedPos;
int baseTransparency = 255;
void setup()
{
  output_path = sketchPath("") + "log_substeps_" + sub_steps + "_relaxation_" + relaxation_steps + ".txt";
  //println(output_path);
  //Load node info from txt
  String[] lines = loadStrings(nodeFile);
  for (int i = 0; i < lines.length; i++){
    String line = lines[i].trim();
    if (line.startsWith("#")){
      continue;
    } else {
      String[] lineParts = line.trim().split(" ");
      int node_id = int(lineParts[0]);
      float x = float(lineParts[1]);
      float y = float(lineParts[2]);
      float z = float(lineParts[3]);
      String node_type = lineParts[4];
      nodeMap.put(node_id, new Node(new Vec3(x, y, z), node_type, node_id));
      //println(node_id, x, y, z, node_type);
    }
  }
  //Load link info from txt
  lines = loadStrings(linkFile);
  for (int i = 0; i < lines.length; i++){
    String line = lines[i].trim();
    if (line.startsWith("#")){
      continue;
    } else {
      String[] lineParts = line.trim().split(" ");
      int link_id = int(lineParts[0]);
      int node1_id = int(lineParts[1]);
      int node2_id = int(lineParts[2]);
      Node n1 = nodeMap.get(node1_id);
      n1.link_id_list.add(link_id);
      Node n2 = nodeMap.get(node2_id);
      n2.link_id_list.add(link_id);
      float link_length = float(lineParts[3]);
      linkMap.put(link_id, new Link(link_id, node1_id, node2_id, link_length));
    }
  }
  //Load tri surface info from txt
  lines = loadStrings(surfaceFile);
  for (int i = 0; i < lines.length; i++){
    String line = lines[i].trim();
    if (line.startsWith("#")){
      continue;
    } else {
      String[] lineParts = line.trim().split(" ");
      int surface_id = int(lineParts[0]);
      int node1_id = int(lineParts[1]);
      int node2_id = int(lineParts[2]);
      int node3_id = int(lineParts[3]);
      float u0 = float(lineParts[4]);
      float v0 = float(lineParts[5]);
      float u1 = float(lineParts[6]);
      float v1 = float(lineParts[7]);
      String surface_type = lineParts[8];
      surfaceMap.put(surface_id, new Surface(surface_id, node1_id, node2_id, node3_id, u0, v0, u1, v1, surface_type));
    }
  }
  //Construct obstacles, for now, hard coded, in the future, we can load them as well
  obstacleMap.put(0, new Obstacle(new Vec3(0.5, 5.5, 0.5), 0.3, "Sphere", 0));
  
  
  size(600, 600, P3D);
  camera = new Camera();
  surface.setTitle("3D Link");
  scene_scale = width / 10.0f;
  cloth_img = loadImage("squere1.png");
  pumpkin_img = loadImage("pumpkin5.png");
  noStroke();
  pumpkin = createShape(SPHERE,0.3  * 0.9 * scene_scale);
  pumpkin.setTexture(pumpkin_img);
  //Init base and node
  
}

boolean rayNodeIntersect(Vec3 rayOrigin, Vec3 rayDir, Vec3 nodeCenter, float nodeRadius, Vec3 intersection){
  Vec3 oc = rayOrigin.minus(nodeCenter);
  float a = dot(rayDir, rayDir);
  float b = 2 * dot(oc, rayDir);
  float c = dot(oc, oc) - nodeRadius * nodeRadius;
  float discriminant = b*b - 4*a*c;
  if (discriminant < 0){
    return false;
  }
  else{
    float t = (-b-sqrt(discriminant)) / (2*a);
    Vec3 temp = rayOrigin.plus(rayDir.times(t));
    intersection.x = temp.x;
    intersection.y = temp.y;
    intersection.z = temp.z;
    return true;
  }
}

void calculate_air_drag(){
  for (Surface s : surfaceMap.values()){
     Node node1 = nodeMap.get(s.node1_id);
     Node node2 = nodeMap.get(s.node2_id);
     Node node3 = nodeMap.get(s.node3_id);
     Vec3 v_avg = node1.vel.plus(node2.vel.plus(node3.vel)).times(1.0/3);
     Vec3 v_diff = v_avg.minus(v_air);
     Vec3 n_star = product(node2.pos.minus(node1.pos), node3.pos.minus(node1.pos));
     Vec3 air_drag_avg =   (n_star.times(v_diff.length() * dot(v_diff, n_star)/(2*n_star.length()))).times(-0.5*density_air*Cd/3);
     Vec3 a_air_drag_avg = air_drag_avg.times(1.0/mass);
     node1.air_drag_a.add(a_air_drag_avg);
     node2.air_drag_a.add(a_air_drag_avg);
     node3.air_drag_a.add(a_air_drag_avg);
  }
}



void update_physics(float dt){
  if (WITHAIRDRAG){
    calculate_air_drag();
  }
  
  for (Node n : nodeMap.values()) {
    if ("Node".equals(n.type) || "BaseNode".equals(n.type)) {
        n.last_pos = n.pos;
        n.vel = n.vel.plus(n.air_drag_a.times(dt));
        //println(n.air_drag_a);
        n.vel = n.vel.plus(gravity.times(dt));
        n.pos = n.pos.plus(n.vel.times(dt));
        n.air_drag_a = new Vec3(0, 0, 0);
    }
  }
  Vec3 delta;
  float delta_len;
  float correction;
  Vec3 delta_normalized;
  for (int i = 0; i < relaxation_steps; i++) {
    //Check whether link is inside the sphere or now
    for (Link l : linkMap.values()) {
      Node node1 = nodeMap.get(l.node1_id);
      Node node2 = nodeMap.get(l.node2_id);
      
      for (Obstacle o : obstacleMap.values()){
        if ("Sphere".equals(o.obstacle_type)){
          Vec3 closestPoint = closestPoint(node1.pos, node2.pos, o.pos);
          Vec3 minDistDir = closestPoint.minus(o.pos);
          float minDist = minDistDir.length();
          if (minDist < o.radius){
            node1.pos.add(minDistDir.normalized().times(o.radius - minDist));
            node2.pos.add(minDistDir.normalized().times(o.radius - minDist));
          } else {
            continue;
          }
        }
      }
    }
    //Go through each link, and update the nodes for each link
    for (Link l : linkMap.values()) {
      Node node1 = nodeMap.get(l.node1_id);
      Node node2 = nodeMap.get(l.node2_id);
      delta = node2.pos.minus(node1.pos);
      delta_len = delta.length();
      correction = delta_len - l.link_length;
      delta_normalized = delta.normalized();
      node2.pos = node2.pos.minus(delta_normalized.times(correction * cor_stretch/ 2));
      node1.pos = node1.pos.plus(delta_normalized.times(correction * cor_stretch / 2));
    }
    
    
    //Move the node with "Base" type back to its defined location
    for (Node n : nodeMap.values()){
      if ("Base".equals(n.type)){
        n.pos = n.init_pos;
      }
    }
    for (Node n : nodeMap.values()){
      if ("Selected".equals(n.type)){
        n.pos = n.temp_init_pos;
      }
    }
  }
  // Update the velocities (PBD)
  for (Node n : nodeMap.values()){
    n.vel = n.pos.minus(n.last_pos).times(cor * 1 / dt);
  }
}

float total_energy(){
  float kinetic_energy = 0;
  float node_height;
  float potential_energy = 0; // PE = m*g*h
  
  for (Node n : nodeMap.values()) {
    kinetic_energy += 0.5 * n.vel.lengthSqr(); // KE = (1/2) * m * v^2
    node_height = (height - n.pos.y * scene_scale) / scene_scale;
    potential_energy += mass * gravity.length() * node_height;
    //println(node_height);
  }
  
  float total_energy = kinetic_energy + potential_energy;
  return total_energy;
}

float total_length_error(){
  float total_length_error = 0;
  for (Link l : linkMap.values()){
    Node node1 = nodeMap.get(l.node1_id);
    Node node2 = nodeMap.get(l.node2_id);
    total_length_error += abs(node1.pos.minus(node2.pos).length() - l.link_length);
  }
  return total_length_error;
}


boolean paused = true;
float time = 0;

int checkChosenNode(){
  Vec3 cameraPos = new Vec3(camera.position.x, camera.position.y, camera.position.z);
  Vec3 mouseDir = new Vec3(camera.mouseDir.x, camera.mouseDir.y, camera.mouseDir.z);
  float minDis = Float.MAX_VALUE;
  int nodeId = -1;
  for (Node n : nodeMap.values()) {
    Vec3 intersection = new Vec3(0, 0, 0);
    Vec3 nodePos = new Vec3(n.pos.x * scene_scale, n.pos.y * scene_scale, n.pos.z * scene_scale);
    boolean isIntersect = rayNodeIntersect(cameraPos, mouseDir, nodePos, 0.03  *  scene_scale, intersection);
    if (isIntersect){
      println("Choose a node");
      //println(intersection.minus(cameraPos).length());
      float currentDis = intersection.minus(cameraPos).length();
      if (intersection.minus(cameraPos).length() < minDis){
        minDis = currentDis;
        nodeId = n.node_id;
      }
    }
  } 
  return nodeId;
}



void keyPressed()
{
  camera.HandleKeyPressed();
  if (key == ' ') {
    if (paused == true){
      try (PrintWriter writer = new PrintWriter(new FileWriter(output_path))){
        writer.println("---- Log file ----\nSub Steps: " + sub_steps + "\nRelaxation Steps: " + relaxation_steps);
        writer.println("------------------");
        writer.println("t total_energy length_error");
        float total_energy = total_energy();
        float total_length_error = total_length_error();
        writer.println(time + " " + total_energy+ " " + total_length_error);
        
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
    paused = !paused;
    
  }
  if (key == 'r') {
    for (Node n : nodeMap.values()) {
      n.reset();
    }
    paused = true;
  }
  if (key == 'z') {
    WITHAIRDRAG  = !WITHAIRDRAG ;
  }
}
void mousePressed(){
  float mx = mouseX / (float) width;
  float my = mouseY / (float) height;
  mousePressedPos = new Vec2(mx, my);
  chosenNodeId = checkChosenNode();
  if (chosenNodeId > -1){
    Node n = nodeMap.get(chosenNodeId);
    if ("Node".equals(n.type) || "BaseNode".equals(n.type)){
      n.temp_init_pos = n.pos;
      n.type = "Selected";
    } 
  }
  mouseIsPressed = true;
  drawSelectedNode();
}

void mouseDragged(){
  float mx = mouseX / (float) width;
  float my = mouseY / (float) height;
  Vec2 mouseCurrentPos = new Vec2(mx, my);
  float mouseMoveDis = mouseCurrentPos.minus(mousePressedPos).length();
  //println(mouseMoveDis);
  if (chosenNodeId > -1){
    Node n = nodeMap.get(chosenNodeId);
    if ("Base".equals(n.type)){
      baseTransparency = max(255 - int(0.8 * min(mouseMoveDis / 0.1 * 255, 255)), 0);
      if (baseTransparency < 55){
        n.type = "BaseNode";
        mouseIsPressed = false;
        chosenNodeId = -1;
        baseTransparency = 255;
      }
    }
  }
  drawSelectedNode();
}

void mouseReleased(){
  if (chosenNodeId > -1){
    Node n = nodeMap.get(chosenNodeId);
    if ("Selected".equals(n.type)){
      n.type = "Node";
    }
  }
  mouseIsPressed = false;
  chosenNodeId = -1;
  baseTransparency = 255;
}

void keyReleased()
{
  camera.HandleKeyReleased();
}

void drawSelectedNode(){
  if (chosenNodeId > -1){
    Node n = nodeMap.get(chosenNodeId);
    if ("Node".equals(n.type) || "Selected".equals(n.type)){
      fill(240, 20, 0);
    } else if ("Base".equals(n.type)){
      fill(255, 200, 255, baseTransparency);
      //println(baseTransparency);
    }
    
    noStroke();           // No outline for the sphere
    pushMatrix();
    translate(n.pos.x * scene_scale, n.pos.y * scene_scale, n.pos.z * scene_scale);
    if ("Base".equals(n.type)){
      sphere( 0.03  *  scene_scale * (1 + float(255 - baseTransparency)/255 * 4));
    }
    else{
      sphere( 0.03  *  scene_scale);
    }
    
    popMatrix();
  }
}


void draw() {
  background(0);
  //noLights();
  lights();
  
  //ambientLight(255, 221, 0);
  //directionalLight(51, 102, 126, -1, 0, 0);
  

  camera.Update(1.0/frameRate);
  
  
  float dt = 1.0 / 80; //Dynamic dt: 1/frameRate;
  
  if (!paused) {
    for (int i = 0; i < sub_steps; i++) {
      time += dt / sub_steps;
      update_physics(dt / sub_steps);
    }
  }
  
  float total_energy = total_energy();
  float total_length_error = total_length_error();
  //println("t:", time, " energy:", total_energy, "length error:", total_length_error);
  if (paused == false){
    try (PrintWriter writer = new PrintWriter(new FileWriter(output_path, true))){
      writer.println(time + " " + total_energy+ " " + total_length_error);
    } catch (IOException e) {
      e.printStackTrace();
    }
    //println(time, total_energy, total_length_error);
  }
  if (mouseIsPressed == false){
    int nodeId = checkChosenNode();
    if (nodeId > -1){
      Node n = nodeMap.get(nodeId);
      fill(20, 240, 0);
      noStroke();           // No outline for the sphere
      pushMatrix();
      translate(n.pos.x * scene_scale, n.pos.y * scene_scale, n.pos.z * scene_scale);
      sphere( 0.03  *  scene_scale);
      popMatrix();
    }
  }
  drawSelectedNode();
  
    
    
  if (DEBUG){
    //Render the nodes
    for (Node n : nodeMap.values()) {
      if ("Base".equals(n.type)){
        fill(200, 20, 0);
      } else{
        fill(20, 240, 0);
      }
      noStroke();           // No outline for the sphere
      pushMatrix();
      translate(n.pos.x * scene_scale, n.pos.y * scene_scale, n.pos.z * scene_scale);
      sphere( 0.03  *  scene_scale);
      popMatrix();
    }
    //Render the link
    for (Link l : linkMap.values()){
      Node node1 = nodeMap.get(l.node1_id);
      Node node2 = nodeMap.get(l.node2_id);
      stroke(0);
      strokeWeight(0.02 * scene_scale);
      line(node1.pos.x * scene_scale, node1.pos.y * scene_scale, node1.pos.z * scene_scale, node2.pos.x * scene_scale, node2.pos.y * scene_scale, node2.pos.z * scene_scale); 
    }  
  }
  
  stroke(0);
  fill(31, 100, 32);
  pushMatrix();
  translate( floor_pos.x* scene_scale, floor_pos.y* scene_scale, floor_pos.z* scene_scale );
  box(5000, 5, 5000);
  popMatrix();
  
  //Render obstacles
  for (Obstacle o : obstacleMap.values()){
    if ("Sphere".equals(o.obstacle_type)){
      fill(255, 117, 24); //Pumpkin color
      noStroke();           // No outline for the sphere
      pushMatrix();
      translate(o.pos.x * scene_scale, o.pos.y * scene_scale, o.pos.z * scene_scale);
      shape(pumpkin);
      //sphere( o.radius  * 0.9 * scene_scale);
      popMatrix();
    }
  }
  noFill();
  //Render cloth
  beginShape(TRIANGLES);
  texture(cloth_img);
  emissive(255, 255, 255);
  for (Surface s : surfaceMap.values()){
    //println(s.surface_type);
    float u0 = s.u0 * cloth_img.width;
    float v0 = s.v0 * cloth_img.height;
    float u1 = s.u1 * cloth_img.width;
    float v1 = s.v1 * cloth_img.height;
    Node node1 = nodeMap.get(s.node1_id);
    Node node2 = nodeMap.get(s.node2_id);
    Node node3 = nodeMap.get(s.node3_id);
    if ("ul".equals(s.surface_type)){
      vertex(node1.pos.x * scene_scale, node1.pos.y * scene_scale, node1.pos.z * scene_scale, u0, v0);
      vertex(node2.pos.x * scene_scale, node2.pos.y * scene_scale, node2.pos.z * scene_scale, u1, v0);
      vertex(node3.pos.x * scene_scale, node3.pos.y * scene_scale, node3.pos.z * scene_scale, u0, v1);
    } else if ("dr".equals(s.surface_type)){
      vertex(node1.pos.x * scene_scale, node1.pos.y * scene_scale, node1.pos.z * scene_scale, u1, v0);
      vertex(node2.pos.x * scene_scale, node2.pos.y * scene_scale, node2.pos.z * scene_scale, u1, v1);
      vertex(node3.pos.x * scene_scale, node3.pos.y * scene_scale, node3.pos.z * scene_scale, u0, v1);
    }
  }
  endShape();
  emissive(0, 26, 51);
  
}
