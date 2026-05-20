package io.bidswipe.app.ui.sellerHub;

import dagger.internal.DaggerGenerated;
import dagger.internal.Factory;
import dagger.internal.Provider;
import dagger.internal.QualifierMetadata;
import dagger.internal.ScopeMetadata;
import io.bidswipe.app.network.repository.DashRepository;
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
public final class SellerHubViewModel_Factory implements Factory<SellerHubViewModel> {
  private final Provider<DashRepository> repoProvider;

  private final Provider<NetworkMonitor> networkMonitorProvider;

  private SellerHubViewModel_Factory(Provider<DashRepository> repoProvider,
      Provider<NetworkMonitor> networkMonitorProvider) {
    this.repoProvider = repoProvider;
    this.networkMonitorProvider = networkMonitorProvider;
  }

  @Override
  public SellerHubViewModel get() {
    return newInstance(repoProvider.get(), networkMonitorProvider.get());
  }

  public static SellerHubViewModel_Factory create(Provider<DashRepository> repoProvider,
      Provider<NetworkMonitor> networkMonitorProvider) {
    return new SellerHubViewModel_Factory(repoProvider, networkMonitorProvider);
  }

  public static SellerHubViewModel newInstance(DashRepository repo, NetworkMonitor networkMonitor) {
    return new SellerHubViewModel(repo, networkMonitor);
  }
}
