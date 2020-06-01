package com.example.gif_image;

import android.content.pm.PackageManager;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.Surface;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.TextureRegistry;

public class ImagePlugin implements MethodChannel.MethodCallHandler, Runnable {

    private final PluginRegistry.Registrar registrar;

    private boolean isDrawing = false;
    private TextureRegistry.SurfaceTextureEntry surfaceTexture;
    private Drawable drawable;
    private Surface surface;


    public ImagePlugin(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_native");
        channel.setMethodCallHandler(new ImagePlugin(registrar));
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "nativeImage":
                String type = methodCall.argument("type");
                String path = methodCall.argument("path");
                isDrawing = true;
                int resourceId = registrar.context().getResources().getIdentifier(path, type, registrar.context().getPackageName());
                drawable = registrar.context().getResources().getDrawable(resourceId);
                drawable.setCallback(registrar.view());
                surfaceTexture = registrar.textures().createSurfaceTexture();
                surface = new Surface(surfaceTexture.surfaceTexture());
                surfaceTexture.surfaceTexture().setDefaultBufferSize(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
                long id = surfaceTexture.id();
                Canvas canvas = surface.lockCanvas(null);
                canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR);
                drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());
                drawable.draw(canvas);
                surface.unlockCanvasAndPost(canvas);


                result.success(id);
                break;
        }
    }

    @Override
    public void run() {


    }
}
