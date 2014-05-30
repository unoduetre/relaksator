public class Head extends Part
{ 
  public Head(PApplet pApplet)
  {
    /*
    Poniższy kod nie jest już aktualny, zachowałem aby on gdzieś był, usunę jak zrobię kod zastępczy
    super(pApplet,new OBJModel(pApplet, "animacja.obj","relative",TRIANGLES));
    model.translate(new PVector(0,-11,0)); //środek na wysokości nosa :-)
    model.scale(1/20.0);
    */
    super(pApplet,"animacja.dae");   
  }
}
