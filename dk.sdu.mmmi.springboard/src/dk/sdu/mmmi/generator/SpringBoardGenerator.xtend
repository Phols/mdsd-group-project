/*
 * generated by Xtext 2.20.0
 */
package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import dk.sdu.mmmi.springBoard.SpringBoard
import dk.sdu.mmmi.springBoard.Package
import javax.inject.Inject
import dk.sdu.mmmi.springBoard.Model

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class SpringBoardGenerator extends AbstractGenerator {
	
	@Inject extension ModelGenerator modelGenerator
	@Inject extension RepositoryGenerator repositoryGenerator
	
	val mavenSrcStructure = "src/main/java/"
	val mavenTestStructure = "src/test/java/"
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
//		fsa.generateFile('greetings.txt', 'People to greet: ' + 
//			resource.allContents
//				.filter(Greeting)
//				.map[name]
//				.join(', '))

		val model = resource.allContents.filter(SpringBoard).next
		val packName = createPackageName(model.pkg)
		
		
		generateSpringProjectStructure(fsa, packName)
		
		model.models.types.filter(Model).forEach[ element |
			modelGenerator.createModel(element, fsa, packName, hasSubclasses(element, model))
			repositoryGenerator.createRepository(element, fsa, packName, hasSubclasses(element, model))
		]
		
	}
	
	/**
	 * Important to check for Spring Data API
	 * https://blog.netgloo.com/2014/12/18/handling-entities-inheritance-with-spring-data-jpa/
	 */
	def hasSubclasses(Model element, SpringBoard model) {
		for (Model m : model.models.types.filter(Model)) {
			if (m.inh !== null && m.inh.base.name == element.name) return true
		}
		return false
	}
	
	/**
	 * TODO: Remove hardcoded names 
	 */
	def generateSpringProjectStructure(IFileSystemAccess2 fsa, String packName) {
		fsa.generateFile("/pom.xml", generatePom(packName))
		fsa.generateFile(mavenSrcStructure+packName.replace('.', '/')+"/DemoApplication.java", generateSource(packName))
		fsa.generateFile(mavenTestStructure+packName.replace('.', '/')+"/DemoApplicationTests.java", generateTest(packName))
		fsa.generateFile("src/main/resources/application.properties", generateProperties())
	}
	
	/**
	 * TODO: should probably be configurable instead of hardcoded database / 
	 * OR: people should make this themselves
	 */
	def CharSequence generateProperties()'''
	# H2
	spring.datasource.url=jdbc:h2:mem:jpadb
	spring.datasource.username=sa
	spring.datasource.password=mypass
	spring.datasource.driverClassName=org.h2.Driver
	spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
	spring.jpa.generate-ddl=true
	spring.jpa.hibernate.ddl-auto=create
	'''
	
	def CharSequence generateTest(String packName)'''
	package �packName�;
	import org.junit.jupiter.api.Test;
	import org.springframework.boot.test.context.SpringBootTest;
	
	@SpringBootTest
	class DemoApplicationTests {
		
	  @Test
	  void contextLoads() {
	  }
	  
	}
	
	'''
	
	
	
	
	
	def createPackageName(Package pack) {
		var packIter = pack
		var name = packIter.name
		
		while (packIter.next !== null) {
			packIter = packIter.next
			name += ('.'+packIter.name)
		}
		return name
	}
	/**
	 * TODO: perhaps include some way of configuring this?
	 */
	def CharSequence generatePom(String packName)'''
	<?xml version="1.0" encoding="UTF-8"?>
	<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	  <modelVersion>4.0.0</modelVersion>
	  <parent>
	    <groupId>org.springframework.boot</groupId>
	    <artifactId>spring-boot-starter-parent</artifactId>
	    <version>2.2.6.RELEASE</version>
	    <relativePath/> <!-- lookup parent from repository -->
	  </parent>
	  
	  <groupId>�packName�</groupId>
	  <artifactId>demo</artifactId>
	  <version>0.0.1-SNAPSHOT</version>
	  <name>demo</name>
	  <description>Demo project for Spring Boot</description>
	  
	  <properties>
	    <java.version>11</java.version>
	  </properties>
	  
	  <dependencies>
	    <dependency>
	      <groupId>org.springframework.boot</groupId>
	      <artifactId>spring-boot-starter-web</artifactId>
	    </dependency>
	    
	    <dependency>
	      <groupId>org.springframework.boot</groupId>
	      <artifactId>spring-boot-starter-test</artifactId>
	      <scope>test</scope>
	      <exclusions>
	        <exclusion>
	          <groupId>org.junit.vintage</groupId>
	          <artifactId>junit-vintage-engine</artifactId>
	        </exclusion>
	      </exclusions>
	    </dependency>
	    
	    <dependency>
	        <groupId>org.springframework.boot</groupId>
	        <artifactId>spring-boot-starter-data-jpa</artifactId>
	    </dependency>
	     
	    <dependency>
	        <groupId>com.h2database</groupId>
	        <artifactId>h2</artifactId>
	        <scope>runtime</scope> 
	    </dependency>
	  </dependencies>
	  <build>
	    <plugins>
	      <plugin>
	        <groupId>org.springframework.boot</groupId>
	        <artifactId>spring-boot-maven-plugin</artifactId>
	      </plugin>
	    </plugins>
	  </build>
	</project>
	'''
	
	def CharSequence generateSource(String packName)'''
	package �packName�;
	
	import org.springframework.boot.SpringApplication;
	import org.springframework.boot.autoconfigure.SpringBootApplication;
	
	@SpringBootApplication
	public class DemoApplication {
	  public static void main(String[] args) {
	    SpringApplication.run(DemoApplication.class, args);
	  }
	}
	'''
}
