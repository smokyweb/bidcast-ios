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
public final class DashRepository_Factory implements Factory<DashRepository> {
  private final Provider<ApiInterface> apiProvider;

  private DashRepository_Factory(Provider<ApiInterface> apiProvider) {
    this.apiProvider = apiProvider;
  }

  @Override
  public DashRepository get() {
    return newInstance(apiProvider.get());
  }

  public static DashRepository_Factory create(Provider<ApiInterface> apiProvider) {
    return new DashRepository_Factory(apiProvider);
  }

  public static DashRepository newInstance(ApiInterface api) {
    return new DashRepository(api);
  }
}
