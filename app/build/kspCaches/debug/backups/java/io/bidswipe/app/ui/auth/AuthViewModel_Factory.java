package io.bidswipe.app.ui.auth;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import io.bidswipe.app.network.repository.AuthRepository;
import io.bidswipe.app.utils.NetworkMonitor;
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
public final class AuthViewModel_Factory implements Factory<AuthViewModel> {
  private final Provider<AuthRepository> repoProvider;

  private final Provider<NetworkMonitor> networkMonitorProvider;

  private AuthViewModel_Factory(Provider<AuthRepository> repoProvider,
      Provider<NetworkMonitor> networkMonitorProvider) {
    this.repoProvider = repoProvider;
    this.networkMonitorProvider = networkMonitorProvider;
  }

  @Override
  public AuthViewModel get() {
    return newInstance(repoProvider.get(), networkMonitorProvider.get());
  }

  public static AuthViewModel_Factory create(Provider<AuthRepository> repoProvider,
      Provider<NetworkMonitor> networkMonitorProvider) {
    return new AuthViewModel_Factory(repoProvider, networkMonitorProvider);
  }

  public static AuthViewModel newInstance(AuthRepository repo, NetworkMonitor networkMonitor) {
    return new AuthViewModel(repo, networkMonitor);
  }
}
