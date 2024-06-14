class Metacall < Formula
  desc "Ultimate polyglot programming experience"
  homepage "https://metacall.io"
  url "https://github.com/metacall/core/archive/refs/tags/v0.7.11.tar.gz"
  sha256 "08cfdddac1e6e0fb845cf4c9c4eb7d1f1f5d762ef7812a5f85163b5a5db568ce"
  license "Apache-2.0"
  head "https://github.com/metacall/core.git", branch: "develop"

  depends_on "cmake" => :build
  depends_on "node@20"
  depends_on "python@3.12"
  depends_on "ruby@2.7"
  depends_on "openjdk"

  def python
    deps.map(&:to_formula)
        .find { |f| f.name.match?(/^python@\d\.\d+$/) }
  end

  # Get Python location
  def python_executable
    python.opt_libexec/"bin/python"
  end

  def install
    Dir.mkdir("build")
    Dir.chdir("build")
    py3ver = Language::Python.major_minor_version python_executable
    py3prefix = if OS.mac?
      python.opt_frameworks/"Python.framework/Versions"/py3ver
    else
      python.opt_prefix
    end
    py3include = py3prefix/"include/python#{py3ver}"
    py3rootdir = py3prefix
    py3lib = py3prefix/"lib/libpython#{py3ver}.dylib"

    cc_compiler = `xcrun --find clang`.tr("\n","")
    cxx_compiler = `xcrun --find clang++`.tr("\n","")
    xcode_prefix = `xcode-select -p`.tr("\n","")
    ENV["SDKROOT"] = `xcrun --show-sdk-path`.tr("\n","")
    ENV["MACOSX_DEPLOYMENT_TARGET"] = ""

    args = std_cmake_args + %W[
      -Wno-dev
      -DCMAKE_C_COMPILER=#{cc_compiler}
      -DCMAKE_CXX_COMPILER=#{cxx_compiler}
      -DCMAKE_INCLUDE_PATH=#{xcode_prefix}/usr/include/c++/v1
      -DCMAKE_BUILD_TYPE=Release
      -DOPTION_BUILD_SECURITY=OFF
      -DOPTION_FORK_SAFE=OFF
      -DOPTION_BUILD_SCRIPTS=OFF
      -DOPTION_BUILD_TESTS=OFF
      -DOPTION_BUILD_EXAMPLES=OFF
      -DOPTION_BUILD_LOADERS_PY=OFF
      -DOPTION_BUILD_LOADERS_NODE=ON
      -DNodeJS_INSTALL_PREFIX=/usr/local/Cellar/metacall/#{version}
      -DOPTION_BUILD_LOADERS_JAVA=OFF
      -DOPTION_BUILD_LOADERS_JS=OFF
      -DOPTION_BUILD_LOADERS_C=OFF
      -DOPTION_BUILD_LOADERS_COB=OFF
      -DOPTION_BUILD_LOADERS_CS=OFF
      -DOPTION_BUILD_LOADERS_RB=OFF
      -DOPTION_BUILD_LOADERS_TS=OFF
      -DOPTION_BUILD_LOADERS_FILE=OFF
      -DOPTION_BUILD_PORTS=ON
      -DOPTION_BUILD_PORTS_PY=OFF
      -DOPTION_BUILD_PORTS_NODE=ON
      -DOPTION_BUILD_PLUGINS_BACKTRACE=OFF
      -DPython3_VERSION=#{py3ver}
      -DPython3_ROOT_DIR=#{py3rootdir}
      -DPython3_EXECUTABLE=#{python_executable}
      -DPython3_LIBRARIES=#{py3lib}
      -DPython3_INCLUDE_DIR=#{py3include}
    ]

    system "cmake", *args, ".."
    system "cmake", "--build", ".", "--target", "install"

    shebang = "\#!/usr/bin/env bash\n"
    # debug = "set -euxo pipefail\n"

    metacall_extra = [
      "PREFIX=/usr/local/Cellar/metacall/#{version}\n",
      "export LOADER_LIBRARY=\"${PREFIX}/lib\"\n",
      "export SERIAL_LIBRARY_PATH=\"${PREFIX}/lib\"\n",
      "export DETOUR_LIBRARY_PATH=\"${PREFIX}/lib\"\n",
      "export PORT_LIBRARY_PATH=\"${PREFIX}/lib\"\n",
      "export CONFIGURATION_PATH=\"${PREFIX}/configurations/global.json\"\n",
    ]
    cmds = [shebang, *metacall_extra]
    cmds.append("export LOADER_SCRIPT_PATH=\"\${LOADER_SCRIPT_PATH:-\`pwd\`}\"\n")
    cmds.append("${PREFIX}/metacallcli $@\n")

    File.open("metacall.sh", "w") do |f|
      f.write(*cmds)
    end

    chmod("u+x", "metacall.sh")
    bin.install "metacall.sh" => "metacall"

    # Clean build data
    system "cmake", "--build", ".", "--target", "clean"
  end

  test do
    (testpath/"test.js").write <<~EOS
      console.log("Hello from NodeJS")
    EOS
    Dir.mkdir(testpath/"typescript")
    (testpath/"typescript/typedfunc.ts").write <<~EOS
      'use strict';
      export function typed_sum(left: number, right: number): number {
        return left+right
      }
      export async function typed_sum_async(left: number, right: number): Promise<number> {
        return left+right
      }
      export function build_name(first: string, last = 'Smith') {
        return`${first} ${last}`
      }
      export function object_pattern_ts({asd}){
        return asd
      }
      export function typed_array(a: number[]): number{
        return a[0]+a[1]+a[2]
      }
      export function object_record(a: Record<string, number>): number {
        return a.element
      }
    EOS
    (testpath/"test_typescript.sh").write <<~EOS
      #!/usr/bin/env bash
      cd typescript
      echo 'load ts typedfunc.ts\ninspect\ncall typed_sum(4321, 50000)\nexit' | #{bin}/metacall
    EOS
    chmod("u+x", testpath/"test_typescript.sh")
    (testpath/"test.py").write <<~EOS
      print("Hello from Python")
    EOS
    (testpath/"test.rb").write <<~EOS
      print("Hello from Ruby")
    EOS
    (testpath/"test.java").write <<~EOS
      public class test {
        public static void main(String[]args) {
          System.err.println("Hello from Java");
        }
      }
    EOS

    # Tests
    assert_match "Hello from Python", shell_output("#{bin}/metacall test.py")
    assert_match "Hello from Ruby", shell_output("#{bin}/metacall test.rb")
    assert_match "Hello from NodeJS", shell_output("#{bin}/metacall test.js")
    assert_match "54321", shell_output(testpath/"test_typescript.sh")

    # TODO
    # assert_match "Hello from Java", shell_output("#{bin}/metacall test.java")
  end
end
