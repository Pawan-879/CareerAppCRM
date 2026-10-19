import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory
import com.android.build.gradle.BaseExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ── Build directory fix ───────────────────────────────────────────────────────
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    pluginManager.withPlugin("com.android.library") {
        extensions.findByName("android")?.let { ext ->
            val androidExt = ext as BaseExtension

            // Namespace fix
            if (androidExt.namespace.isNullOrEmpty()) {
                androidExt.namespace =
                    project.group.toString().ifEmpty {
                        project.name
                            .replace("-", "_")
                            .replace(Regex("[^a-zA-Z0-9_]"), "")
                    }
            }

            androidExt.apply {
                compileSdkVersion(35)
            }
        }
    }

    pluginManager.withPlugin("com.android.application") {
        extensions.findByName("android")?.let { ext ->
            val androidExt = ext as BaseExtension
            androidExt.apply {
                compileSdkVersion(35)
            }
        }
    }
}

// ── Clean task ────────────────────────────────────────────────────────────────
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}