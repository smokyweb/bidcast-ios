package io.bidswipe.app.base;

import dagger.hilt.InstallIn;
import dagger.hilt.android.components.ActivityComponent;
import dagger.hilt.codegen.OriginatingElement;
import dagger.hilt.internal.GeneratedEntryPoint;
import java.lang.SuppressWarnings;
import javax.annotation.processing.Generated;

@OriginatingElement(
    topLevelClass = BaseActivity.class
)
@GeneratedEntryPoint
@InstallIn(ActivityComponent.class)
@Generated("dagger.hilt.android.processor.internal.androidentrypoint.InjectorEntryPointGenerator")
@SuppressWarnings("PropertyName")
public interface BaseActivity_GeneratedInjector {
  void injectBaseActivity(BaseActivity baseActivity);
}
