package io.bidswipe.app.di;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Preconditions;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import io.bidswipe.app.network.ApiInterface;
import io.bidswipe.app.network.repository.AuthRepository;
import javax.annotation.processing.Generated;

@ScopeMetadata("javax.inject.Singleton")
@QualifierMetadata
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
public final class AppModule_ProvideAppRepositoryFactory implements Factory<AuthRepository> {
  private final Provider<ApiInterface> apiProvider;

  private AppModule_ProvideAppRepositoryFactory(Provider<ApiInterface> apiProvider) {
    this.apiProvider = apiProvider;
  }

  @Override
  public AuthRepository get() {
    return provideAppRepository(apiProvider.get());
  }

  public static AppModule_ProvideAppRepositoryFactory create(Provider<ApiInterface> apiProvider) {
    return new AppModule_ProvideAppRepositoryFactory(apiProvider);
  }

  public static AuthRepository provideAppRepository(ApiInterface api) {
    return Preconditions.checkNotNullFromProvides(AppModule.INSTANCE.provideAppRepository(api));
  }
}
