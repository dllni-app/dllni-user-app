allprojects {
    buildscript {
        repositories {
            // Official Google CDN fallback for older Android Gradle plugins.
            maven("https://redirector.gvt1.com/edgedl/dl/android/maven2/")
        }
    }
    repositories {
        maven("https://redirector.gvt1.com/edgedl/dl/android/maven2/")
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
