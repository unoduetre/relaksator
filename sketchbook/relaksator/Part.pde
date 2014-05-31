public static abstract class Part extends Widget
{
  private Collada collada = null;
  public Part(PApplet pApplet, String fileName) throws Exception
  {
    super(pApplet);
    collada = new Collada(pApplet.loadXML(fileName));
  }
 
  public void draw()
  {
  }
}


