package net.adoptium.release

import groovy.cli.picocli.CliBuilder
import groovy.cli.picocli.OptionAccessor
import groovy.transform.CompileStatic
import org.kohsuke.github.*
import org.kohsuke.github.extras.ImpatientHttpConnector

import java.nio.file.Files
import java.util.concurrent.TimeUnit

@CompileStatic
class UploadAdoptReleaseFiles {

    private final String tag
    private final String description
    private final String git_token
    private final boolean release
    private final List<File> files
    private final String version
    private final String server
    private final String user_and_repo

    UploadAdoptReleaseFiles(String tag, String description, String git_token, boolean release, String version, String server, String user_and_repo, List<File> files) {
        this.tag = tag
        this.description = description
        this.git_token = git_token
        this.release = release
        this.files = files
        this.version = version
        this.server = server
        this.user_and_repo = user_and_repo

		System.out.println("adfarley: Parsed args start")
		System.out.println("tag = " + this.tag)
        System.out.println("description = " + this.description)
        System.out.println("release = " + this.release)
        System.out.println("files = " + this.files)
        System.out.println("version = " + this.version)
        System.out.println("server = " + this.server)
        System.out.println("user_and_repo = " + this.user_and_repo)
		System.out.println("adfarley: Parsed args end")
    }

    void release() {
        def grouped = files.groupBy {
            switch (it.getName()) {
                case ~/.*hotspot.*/: "adopt"; break;
            }
        }
        GHRepository repo = getRepo("adopt")
        GHRelease release = getRelease(repo)
        uploadFiles(release, grouped.get("adopt"))
    }

    private GHRepository getRepo(String vendor) {
        if (git_token.equals("notoken")) {
            System.err.println("Could not find GITHUB_TOKEN")
            System.exit(1)
        }

        println("Using Github server:'${server}'")
        GitHub github = GitHub.connectUsingOAuth(server, git_token)

        github
                .setConnector(new ImpatientHttpConnector(new HttpConnector() {
                    HttpURLConnection connect(URL url) throws IOException {
                        return (HttpURLConnection) url.openConnection()
                    }
                },
                        (int) TimeUnit.SECONDS.toMillis(120),
                        (int) TimeUnit.SECONDS.toMillis(120)))

        println("Using Github repo:'${user_and_repo}'")
        // jdk11 => 11
        def numberVersion = version.replaceAll(/[^0-9]/, "")

        return github.getRepository(user_and_repo)
    }

    private void uploadFiles(GHRelease release, List<File> files) {
    	println("debug 1")
        List<GHAsset> assets = release.getAssets()
        println("debug 2")
        files.each { file ->
            // Delete existing asset
            assets
                    .find({ it.name == file.name })
                    .each { GHAsset existing ->
                        println("Updating ${existing.name}")
                        existing.delete()
                    }
			println("debug 2.5")
            println("Uploading ${file.name}")
            release.uploadAsset(file, Files.probeContentType(file.toPath()))
        }
        println("debug 3")
    }

    private GHRelease getRelease(GHRepository repo) {
        GHRelease release = repo
                .getReleaseByTagName(tag)

        if (release == null) {
            release = repo
                    .createRelease(tag)
                    .body(description)
                    .name(tag)
                    .prerelease(!this.release)
                    .create()
        }
        return release
    }
}


static void main(String[] args) {
	System.out.println("adfarley: args start")
	for (int i = 0; i < args.length; i++) {
		System.out.println(args[i])
	}
	System.out.println("adfarley: args end")

    OptionAccessor options = parseArgs(args)

    List<File> files = options.arguments()
            .collect { new File(it) }

    new UploadAdoptReleaseFiles(
            options.t,
            options.d,
            options.g,
            options.r,
            options.v,
            options.s,
            options.u,
            files,
    ).release()
}

private OptionAccessor parseArgs(String[] args) {

    CliBuilder cliBuilder = new CliBuilder()

    cliBuilder
            .with {
                v longOpt: 'version', type: String, args: 1, 'JDK version'
                t longOpt: 'tag', type: String, args: 1, 'Tag name'
                d longOpt: 'description', type: String, args: 1, 'Release description'
                g longOpt: 'git_token', type: String, args: 1, 'Token for github server'
                r longOpt: 'release', 'Is a release build'
                h longOpt: 'help', 'Show usage information'
                s longOpt: 'server', type: String, args: 1, optionalArg: true, defaultValue: 'https://api.github.com', 'Github server'
                u longOpt: 'user_and_repo', type: String, args: 1, optionalArg: true, defaultValue: 'no_repo_provided', 'Github user and repo'
            }

    def options = cliBuilder.parse(args)
    if (options.v && options.t && options.d) {
        return options
    }
    cliBuilder.usage()
    System.exit(1)
    return null
}
