class Link {
  int link_id;
  int node1_id;
  int node2_id;
  float link_length;
  Link(int link_id, int node1_id, int node2_id, float link_length) {
    this.link_id = link_id;
    this.node1_id = node1_id;
    this.node2_id = node2_id;
    this.link_length = link_length;
  }
}
