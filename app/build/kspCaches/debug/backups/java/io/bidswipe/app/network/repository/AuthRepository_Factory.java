package io.bidswipe.app.network.repository;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import io.bidswipe.app.network.ApiInterface;
import javax.annotation.processing.Generated;

@ScopeMetadata
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
public final class AuthRepository_Factory implements Factory<AuthRepository> {
  private final Provider<ApiInterface> apiProvider;

  private AuthRepository_Factory(Provider<ApiInterface> apiProvider) {
    this.apiProvider = apiProvider;
  }

  @Override
  public AuthRepository get() {
    return newInstance(apiProvider.get());
  }

  public static AuthRepository_Factory create(Provider<ApiInterface> apiProvider) {
    return new AuthRepository_Factory(apiProvider);
  }

  public static AuthRepository newInstance(ApiInterface api) {
    return new AuthRepository(api);
  }
}
