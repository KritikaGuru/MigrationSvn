Name:    unicon
Version: 13.1.2
Release: 1%{?dist}
Summary: The Unicon Programming Language

License: GPLv2+
Source0: unicon-13.1.2.tar.gz

BuildRequires: libjpeg-devel, libpng-devel, libX11-devel
BuildRequires: mesa-libGL-devel, mesa-libGLU-devel
BuildRequires: openal-devel, freealut-devel, libogg-devel, libvorbis-devel
BuildRequires: openssl-devel, unixODBC-devel
BuildRequires: libXft-devel, freetype-devel


Requires: libjpeg.so, libpng.so, libX11.so, libz.so
Requires: libGL.so, libGLU.so
Requires: libopenal.so, libalut.so, libogg.so, libvorbis.so
Requires: openssl.so, libcrypto.so, libodbc.so
Requires: libXft.so, libfreetype.so


Requires(post): info
Requires(preun): info

%description
Interpreter and tools for Unicon, a high-level programming language
 Unicon is a "modern dialect" descending from the Icon programming language.
 Unicon incorporates numerous new features and extensions to make the Icon
 language more suitable for a broad range of real-world applications.


%global debug_package %{nil}

%prep
%autosetup -n unicon



%build
./configure --prefix=/usr --bindir=%{_bindir} --libdir=%{_libdir} --mandir=%{_mandir} --docdir=%{_docdir}
make -j8

%install
rm -rf $RPM_BUILD_ROOT
%make_install

%{buildroot}/%{_bindir}/patchstr  -DPatchUnirotHere %{buildroot}/%{_bindir}/iconx %{_libdir}/unicon
%{buildroot}/%{_bindir}/patchstr  -DPatchUnirotHere %{buildroot}/%{_bindir}/icont %{_libdir}/unicon
%{buildroot}/%{_bindir}/patchstr  -DPatchUnirotHere %{buildroot}/%{_bindir}/iconc /usr/lib/unicon

#rm -f %{buildroot}/%{_infodir}/dir

%post
#%{_bindir}/patchstr  -DPatchUnirotHere /usr/bin/iconx /usr/lib/unicon                                                                                                                   
#%{_bindir}/patchstr  -DPatchUnirotHere /usr/bin/icont /usr/lib/unicon                                                                                                                   
#%{_bindir}/patchstr  -DPatchUnirotHere /usr/bin/iconc /usr/lib/unicon                                                                                                                   


#/sbin/install-info %{_infodir}/%{name}.info %{_infodir}/dir || :                                                                                                                        

%preun
#if [ $1 = 0 ] ; then                                                                                                                                                                    
#/sbin/install-info --delete %{_infodir}/%{name}.info %{_infodir}/dir || :                                                                                                               
#fi                                                                                                                                                                                      

%files
#{_mandir}/man1/unicon.1                                                                                                                                                                 
%{_docdir}/unicon/README
%{_bindir}/iconx
%{_bindir}/icont
%{_bindir}/iconc
%{_bindir}/unicon
%{_bindir}/ivib
%{_bindir}/ui
%{_bindir}/UniDoc
%{_bindir}/udb
%{_bindir}/unidep
%{_bindir}/uprof
%{_bindir}/iyacc
%{_bindir}/patchstr
%{_libdir}/unicon/ipl/lib/*.u
%{_libdir}/unicon/ipl/incl/*.icn
%{_libdir}/unicon/ipl/gincl/*.icn
%{_libdir}/unicon/ipl/mincl/*.icn
%{_libdir}/unicon/uni/lib/*.*
%{_libdir}/unicon/uni/3d/*.*
%{_libdir}/unicon/uni/gui/*.*
%{_libdir}/unicon/uni/unidoc/*.*
%{_libdir}/unicon/uni/unidep/*.*
%{_libdir}/unicon/uni/parser/*.*
%{_libdir}/unicon/uni/xml/*.*
%{_libdir}/unicon/plugins/lib/*.*
%{_docdir}/unicon/*.*
%{_mandir}/man1/unicon.1.gz


#%doc AUTHORS ChangeLog NEWS README THANKS TODO                                                                                                                                          
%license COPYING

%changelog
* Fri Mar 29 2019 Jafar Al-Gharaibeh <to.Jafar@gmail.com> 13.1.0-1
- Initial version of the package

