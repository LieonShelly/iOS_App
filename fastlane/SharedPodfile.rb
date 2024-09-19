require 'cocoapods'

$projectPath = '.'
$framrworkPath = '.'

ThirdPod = Struct.new(:name, :version, :is_static, :branch, :configurations, :url, :podspec, :http, :commit)

# global third pod
$zipFoundation = ThirdPod.new('ZIPFoundation', '0.9.18')
$alamofire = ThirdPod.new('Alamofire', '5.9.1')

def install_third_pod(*third_party_pods)
    third_party_pods.each do |third_party_pod|
        if third_party_pod.url
            pod third_party_pod.name, git: third_party_pod.url, tag: third_party_pod.version, branch:third_party_pod.branch, commit: third_party_pod.commit
        elsif third_party_pod.podspec
            pod third_party_pod.name, podspec: third_party_pod.podspec
        elsif third_party_pod.http
            pod third_party_pod.name, http: third_party_pod.http
        else
            pod third_party_pod.name, third_party_pod.version
        end 
    end
end

def user_presentation
    target 'UserPresentation' do
        use_frameworks!
        project "#{$projectPath}/domain/UserPresentation/UserPresentation.xcodeproj"
        # import third framework here
        # install_third_pod $zipFoundation

        target 'UserPresentationTests' do
            inherit! :complete
            # import third framework here test target need 
        end
    end
end

def user_service
    target 'UserService' do
        use_frameworks!
        project "#{$projectPath}/service/UserService/UserService.xcodeproj"
        target 'UserServiceTests' do
            inherit! :complete
            install_third_pod $alamofire
        end
    end
end

def uicomponent
    target 'UIComponent' do
        use_frameworks!
        project "#{$projectPath}/core/UIComponent/UIComponent.xcodeproj"
        target 'UIComponentTests' do
            inherit! :complete
            # import third framework here test target need 
        end
    end
end