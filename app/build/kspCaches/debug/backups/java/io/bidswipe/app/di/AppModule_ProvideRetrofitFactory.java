package io.bidswipe.app.di;

import android.content.Context;
import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import io.bidswipe.app.network.ApiInterface;
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
public final class AppModule_ProvideRetrofitFactory implements Factory<ApiInterface> {
  private final Provider<Context> mCtxProvider;

  private AppModule_ProvideRetrofitFactory(Provider<Context> mCtxProvider) {
    this.mCtxProvider = mCtxProvider;
  }

  @Override
  public ApiInterface get() {
    return provideRetrofit(mCtxProvider.get());
  }

  public static AppModule_ProvideRetrofitFactory create(Provider<Context> mCtxProvider) {
    return new AppModule_ProvideRetrofitFactory(mCtxProvider);
  }

  public static ApiInterface provideRetrofit(Context mCtx) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideRetrofit(mCtx));
  }
}
