package io.bidswipe.app.ui.watchStream;

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
public final class StreamViewModel_Factory implements Factory<StreamViewModel> {
  private final Provider<DashRepository> repoProvider;

  private final Provider<NetworkMonitor> networkMonitorProvider;

  private StreamViewModel_Factory(Provider<DashRepository> repoProvider,
      Provider<NetworkMonitor> networkMonitorProvider) {
    this.repoProvider = repoProvider;
    this.networkMonitorProvider = networkMonitorProvider;
  }

  @Override
  public StreamViewModel get() {
    return newInstance(repoProvider.get(), networkMonitorProvider.get());
  }

  public static StreamViewModel_Factory create(Provider<DashRepository> repoProvider,
      Provider<NetworkMonitor> networkMonitorProvider) {
    return new StreamViewModel_Factory(repoProvider, networkMonitorProvider);
  }

  public static StreamViewModel newInstance(DashRepository repo, NetworkMonitor networkMonitor) {
    return new StreamViewModel(repo, networkMonitor);
  }
}
