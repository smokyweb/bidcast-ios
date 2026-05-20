package io.bidswipe.app.di;

import android.content.Context;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import io.bidswipe.app.utils.NetworkMonitor;
import javax.annotation.processing.Generated;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata("dagger.hilt.android.qualifiers.ApplicationContext")
@DaggerGenerated
@Generated(
    value = "dagger.internal.codegen.ComponentProcessor",
    comments = "https://dagger.dev"
)
@SuppressWarnings({
    "unchecked",
    "rawtypes",
    "KotlinInternal",
    "KotlinInternalInJava",
    "cast",
    "deprecation",
    "nullness:initialization.field.uninitialized"
})
public final class AppModule_ProvideNetworkMonitorFactory implements Factory<NetworkMonitor> {
  private final Provider<Context> contextProvider;

  private AppModule_ProvideNetworkMonitorFactory(Provider<Context> contextProvider) {
    this.contextProvider = contextProvider;
  }

  @Override
  public NetworkMonitor get() {
    return provideNetworkMonitor(contextProvider.get());
  }

  public static AppModule_ProvideNetworkMonitorFactory create(Provider<Context> contextProvider) {
    return new AppModule_ProvideNetworkMonitorFactory(contextProvider);
  }

  public static NetworkMonitor provideNetworkMonitor(Context context) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideNetworkMonitor(context));
  }
}
