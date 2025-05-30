defmodule NervesContainersBananapiM1.MixProject do
  use Mix.Project

  @github_organization "nerves-containers"
  @app :nerves_containers_bananapi_m1
  @source_url "https://github.com/#{@github_organization}/#{@app}"
  @version Path.join(__DIR__, "VERSION")
           |> File.read!()
           |> String.trim()

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.6",
      compilers: Mix.compilers() ++ [:nerves_package],
      nerves_package: nerves_package(),
      description: description(),
      package: package(),
      deps: deps(),
      aliases: [loadconfig: [&bootstrap/1]],
      docs: docs(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.build": :docs,
        "hex.publish": :docs
      }
    ]
  end

  def application do
    []
  end

  defp bootstrap(args) do
    set_target()
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  defp nerves_package do
    [
      type: :system,
      artifact_sites: [
        # {:github_releases, "#{@github_organization}/#{@app}"}
        {:prefix, "https://nerves-containers.steffend.me/artifacts/"}
      ],
      build_runner_opts: build_runner_opts(),
      platform: Nerves.System.BR,
      platform_config: [
        defconfig: "nerves_defconfig"
      ],
      # The :env key is an optional experimental feature for adding environment
      # variables to the crosscompile environment. These are intended for
      # llvm-based tooling that may need more precise processor information.
      env: [
        {"TARGET_ARCH", "arm"},
        {"TARGET_CPU", "cortex_a7"},
        {"TARGET_OS", "linux"},
        {"TARGET_ABI", "gnueabihf"}
      ],
      checksum: package_files()
    ]
  end

  defp deps do
    [
      {:nerves, "~> 1.11", runtime: false},
      {:nerves_system_br, "1.30.1", runtime: false},
      {:nerves_toolchain_armv7_nerves_linux_gnueabihf, "~> 13.2.0", runtime: false},
      {:nerves_system_linter, "~> 0.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: :docs, runtime: false}
    ]
  end

  defp description do
    """
    Nerves System - Banana Pi M1
    """
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      assets: "assets",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp package do
    [
      files: package_files(),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp package_files do
    [
      "boot.cmd",
      "fwup_include",
      "rootfs_overlay",
      "fwup-ops.conf",
      "fwup.conf",
      "mix.exs",
      "linux.fragment",
      "busybox.fragment",
      "nerves_defconfig",
      "post-build.sh",
      "post-createfs.sh",
      "README.md",
      "VERSION"
    ]
  end

  defp build_runner_opts() do
    # Download source files first to get download errors right away.
    [make_args: primary_site() ++ ["source", "all"]]
  end

  defp primary_site() do
    case System.get_env("BR2_PRIMARY_SITE") do
      nil -> []
      primary_site -> ["BR2_PRIMARY_SITE=#{primary_site}"]
    end
  end

  defp set_target() do
    if function_exported?(Mix, :target, 1) do
      apply(Mix, :target, [:target])
    else
      System.put_env("MIX_TARGET", "target")
    end
  end
end
