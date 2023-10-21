class Node {
  int node_id;
  Vec3 pos;
  Vec3 vel;
  Vec3 last_pos;
  Vec3 init_pos;
  Vec3 temp_init_pos; //Set the value when the node is selected
  String type;
  Vec3 air_drag_a;
  ArrayList<Integer> link_id_list;
  Node(Vec3 pos, String type, int node_id) {
    this.pos = pos;
    this.vel = new Vec3(0, 0, 0);
    this.last_pos = pos;
    this.type = type;
    this.node_id = node_id;
    this.init_pos = pos;
    this.air_drag_a = new Vec3(0, 0, 0);
    this.link_id_list = new ArrayList<Integer>();
  }
  public void reset(){
    this.pos = init_pos;
    this.vel = new Vec3(0, 0, 0);
    this.last_pos = init_pos;
    if ("BaseNode".equals(this.type)) {
      this.type = "Base";
    }
  }
}
