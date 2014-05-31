import ketai.camera.*;
import android.hardware.Camera;

public static class ImageGetter {
  
  private PApplet pApplet;
  
  ImageGetter(PApplet pApplet) {
    this.pApplet = pApplet;
  }
  
  public PImage getImage() {
    // Get parameters
    Camera aCam = Camera.open();
    Camera.Parameters aCamParams = aCam.getParameters();
    aCam.release();
    Camera.Size aCamSize = aCamParams.getPictureSize();
    int fpsRange[] = new int[2];
    aCamParams.getPreviewFpsRange(fpsRange);
    int fps = (fpsRange[0] + fpsRange[1] + 1) >> 1;
    
    // Use KetaiCamera
    KetaiCamera cam = new KetaiCamera(pApplet, aCamSize.width, aCamSize.height, fps);
    
    // Start, wait, read, make a copy, stop, return
    cam.start();
    float frameTime = 1.0 / (float) fps;
    int delayMs = (int) (frameTime * 1000.0 * 2.0 + 0.5);
    pApplet.delay(delayMs);
    
    cam.read();
    
    PImage result = cam.get();
    
    cam.stop();
    
    return result;
  }
}
