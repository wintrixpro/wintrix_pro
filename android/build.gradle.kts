// Root build.gradle.kts
buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Build directory ko configure karna
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")

rootProject.layout.buildDirectory.value(newBuildDir.get())

subprojects {
    // Har subproject ka build dir alag folder mein set karna
    val subprojectBuildDir = newBuildDir.map { it.dir(project.name) }
    project.layout.buildDirectory.value(subprojectBuildDir.get())
}

// Clean task jo sab kuch delete kar de
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
