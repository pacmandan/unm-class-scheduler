import { connect } from 'react-redux';
import CourseTag from './CourseTag';
import { Section } from './catalog';
import { RootState } from './store';

const mapStateToProps = (state: RootState) => ({sections: state.search.results})

const Sandbox = ({sections}: {sections:Section[]}) => {
    return (<div>
        <h1>Sandbox!</h1><br/>
        <div className='flex-auto bg-slate-500 h-auto w-auto'>
            {sections.map(function(section) {
                return <CourseTag section={section} />
            })}
        </div>
    </div>)
}

export default connect(mapStateToProps)(Sandbox)